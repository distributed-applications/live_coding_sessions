defmodule DemoBrowsersGS do
  use GenServer

  def start(args \\ []), do: GenServer.start(__MODULE__, args, name: __MODULE__)

  def request_browsers(pid), do: GenServer.call(pid, :request_browsers)

  def add_browser_hit(server_pid, browser) do
    GenServer.cast(server_pid, {:browser_hit, browser})
  end

  def init(_args), do: {:ok, %{}}

  def handle_call(:request_browsers, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:browser_hit, browser}, browser_state) do
    new_state =
      case Map.fetch(browser_state, browser) do
        :error -> Map.put_new(browser_state, browser, 1)
        {:ok, n} -> Map.put(browser_state, browser, n + 1)
      end

    {:noreply, new_state}
  end
end
