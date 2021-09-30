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

defmodule BrowserInteract do
  use GenServer

  def start(args \\ []) do
    GenServer.start(__MODULE__, args)
  end

  def init(args) do
    browser = args[:browser] || raise "configure browser"

    :timer.send_interval(1000, :add_hit)

    {:ok, %{browser: browser}}
  end

  def handle_info(:add_hit, state) do
    DemoBrowsersGS
    |> Process.whereis()
    |> DemoBrowsersGS.add_browser_hit(state.browser)

    {:noreply, state}
  end
end

# Voorbeeldgebruik in iex shell: (iex demo_browser_interact.exs)
# ===========================================================================
# DemoBrowsersGS.start
# Je kan checken of het name registered is met:
# Process.whereis DemoBrowsersGS
# EXTRA: Probeer het proces nog eens opnieuw te starten, en kijk welke error er verschijnt.
# ===========================================================================
# Daarna starten we 2 processen die per seconde een browser hit emuleren
# BrowserInteract.start  => dit geeft een error dat je je browser moet configureren!
# BrowserInteract.start [browser: "firefox"]
# BrowserInteract.start [browser: "brave"]
# ===========================================================================
# Kijk na of je de hits ziet verhogen
# DemoBrowsersGS |> Process.whereis |> DemoBrowsersGS.request_browsers
