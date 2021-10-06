defmodule TestGsOne do
  use GenServer
  @me __MODULE__

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def init(_args) do
    :timer.send_interval(5000, :annoy)
    {:ok, :no_state}
  end

  def handle_info(:annoy, state) do
    TestGsTwo.annoy()
    {:noreply, state}
  end
end
