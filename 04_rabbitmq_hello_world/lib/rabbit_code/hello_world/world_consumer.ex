defmodule RabbitCode.HelloWorld.WorldConsumer do
  use GenServer
  use AMQP

  require IEx

  # Most of this code is from https://hexdocs.pm/amqp/readme.html#setup-a-consumer-genserver

  @channel :world_consume_channel
  @exchange "hello-exchange"
  @queue "hello-queue"
  # @queue_error "#{@queue}_error"
  @me __MODULE__

  @enforce_keys [:channel, :consumer_tag]
  defstruct [:channel, :consumer_tag]

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    {:ok, _} = Queue.declare(amqp_channel, @queue)
    :ok = Queue.bind(amqp_channel, @queue, @exchange)

    # Limit unacknowledged messages to 5
    # docs: https://hexdocs.pm/amqp/AMQP.Basic.html#qos/2
    :ok = Basic.qos(amqp_channel, prefetch_count: 50)

    # Register the GenServer process as a consumer. Consumer pid argument (3rd arg) defaults to self()
    # docs: https://hexdocs.pm/amqp/AMQP.Basic.html#consume/4
    {:ok, consumer_tag} = Basic.consume(amqp_channel, @queue)

    state = %@me{channel: amqp_channel, consumer_tag: consumer_tag}
    {:ok, state}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, %@me{} = state) do
    # do nothing
    {:noreply, state}
  end

  def handle_info({:basic_deliver, payload, meta_info}, %@me{} = s) do
    # Feel free to inspect the meta info
    # IO.inspect(meta_info)
    # You might want to run payload consumption in separate Tasks in production
    consume(s.channel, meta_info.delivery_tag, meta_info.redelivered, payload)
    {:noreply, %@me{} = s}
  end

  defp consume(channel, tag, redelivered, payload) do
    case payload do
      "hello" ->
        IO.puts("Hello world")
        Basic.ack(channel, tag)
    end
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    exception ->
      :ok = Basic.reject(channel, tag, requeue: not redelivered)
      IO.puts("Error converting #{payload} to integer.\nException is #{inspect(exception)}")
  end
end
