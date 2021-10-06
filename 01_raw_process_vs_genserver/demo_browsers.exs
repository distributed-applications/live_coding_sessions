defmodule DemoBrowsers do
  # API
  def start(args \\ []) do
    spawn(__MODULE__, :private_init, [args])
  end

  def request_browsers(dest_pid) do
    send(dest_pid, {:retrieve_browsers, self()})

    receive do
      {:response_browser, value} -> value
    after
      5000 -> {:error, :timeout}
    end
  end

  def add_browser_hit(dest_pid, browser) do
    send(dest_pid, {:browser_hit, browser})
  end

  # Callbacks
  def private_init(_args) do
    # Will look like %{"Firefox" => N}
    initial_state = %{}
    loop(initial_state)
  end

  # Server
  def loop(browser_state) do
    receive do
      {:retrieve_browsers, pid} ->
        send(pid, {:response_browser, browser_state})
        loop(browser_state)

      {:browser_hit, browser} ->
        new_state =
          case Map.fetch(browser_state, browser) do
            :error -> Map.put_new(browser_state, browser, 1)
            {:ok, n} -> Map.put(browser_state, browser, n + 1)
          end

        loop(new_state)
    end
  end
end

# pid = DemoBrowsers.start
# send pid, {:retrieve_browsers, self()}
