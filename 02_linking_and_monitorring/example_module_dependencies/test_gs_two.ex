defmodule TestGsTwo do
  use GenServer
  @me __MODULE__

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)

  def annoy, do: GenServer.cast(@me, :annoy)

  def init(_args), do: {:ok, :no_state}

  def handle_cast(:annoy, state) do
    IO.puts("being annoyed")
    {:noreply, state}
  end
end
