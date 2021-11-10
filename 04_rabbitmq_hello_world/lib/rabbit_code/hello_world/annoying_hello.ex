defmodule RabbitCode.HelloWorld.AnnoyingHello do
  use GenServer

  @me __MODULE__

  def start_link(_args \\ []) do
    GenServer.start_link(@me, :no_state, name: @me)
  end

  @impl true
  def init(:no_state) do
    :timer.send_interval(1000, :annoying_hello)
    {:ok, :no_state}
  end

  @impl true
  def handle_info(:annoying_hello, :no_state) do
    RabbitCode.HelloWorld.HelloPublisher.publish_hello()
    {:noreply, :no_state}
  end
end
