defmodule RabbitCode.HelloWorld.HelloPublisher do
  use GenServer
  require IEx
  require Logger

  @channel :hello_produce_channel
  @exchange "hello-exchange"
  @queue "hello-queue"

  @me __MODULE__

  @enforce_keys [:channel]
  defstruct [:channel]

  ## API ##

  def start_link(_args \\ []), do: GenServer.start_link(@me, :no_opts, name: @me)
  def publish_hello(), do: GenServer.cast(@me, {:publish, :hello})

  ## Callbacks ##

  @impl true
  def init(:no_opts) do
    {:ok, amqp_channel} = AMQP.Application.get_channel(@channel)
    state = %@me{channel: amqp_channel}
    rabbitmq_setup(state)

    {:ok, state}
  end

  @impl true
  def handle_cast({:publish, :hello}, %@me{channel: c} = state) do
    next_seqno = AMQP.Confirm.next_publish_seqno(c)
    IO.puts("next seqno will be #{next_seqno}")

    # docs: https://hexdocs.pm/amqp/AMQP.Basic.html#publish/5
    :ok = AMQP.Basic.publish(c, @exchange, "", "hello")
    {:noreply, state}
  end

  @impl true
  def handle_info({:basic_ack, integer, multiple}, %@me{} = state) do
    # do nothing
    IO.puts("Received ack #{integer} with bool value: #{multiple}")
    # multiple is a boolean, when true means multiple messages confirm, up to seqno.
    {:noreply, state}
  end

  ## Helper functions ##

  defp rabbitmq_setup(%@me{} = state) do
    # Creates an exchange. Note: docs "Basic.error" isn't an actual error that is returned. It just crashes!!!
    # docs: https://hexdocs.pm/amqp/AMQP.Exchange.html#declare/4
    :ok = AMQP.Exchange.declare(state.channel, @exchange, :direct)

    # Right now messages are lost (black hole effect) when publishing, create a queue and bind it to the exchange
    # docs: https://hexdocs.pm/amqp/AMQP.Queue.html#declare/3
    {:ok, _consumer_and_msg_info} = AMQP.Queue.declare(state.channel, @queue)

    # And bind the queue to the exchange
    # docs: https://hexdocs.pm/amqp/AMQP.Queue.html#bind/4
    :ok = AMQP.Queue.bind(state.channel, @queue, @exchange)

    # Enable acknowledgements
    # https://hexdocs.pm/amqp/AMQP.Confirm.html#register_handler/2
    AMQP.Confirm.register_handler(state.channel, self())
    AMQP.Confirm.select(state.channel)
  end
end
