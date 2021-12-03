defmodule DemoFrontend1.LogDatabase do
  use GenServer

  @me __MODULE__

  # API #
  def start_link(args), do: GenServer.start_link(@me, args, name: @me)
  def store(msg), do: GenServer.cast(@me, {:store, msg})
  def get_logs(:short), do: GenServer.call(@me, {:get_logs, :short})
  def get_logs(:all), do: GenServer.call(@me, {:get_logs, :long})

  # CALLBACKS #

  @impl true
  def init(_args), do: {:ok, []}
  @impl true
  def handle_cast({:store, msg}, state_logs) when is_binary(msg),
    do: {:noreply, [msg | state_logs]}

  @impl true
  def handle_cast({:store, msg}, state_logs) when is_map(msg),
    do: {:noreply, [Kernel.inspect(msg) | state_logs]}

  @impl true
  def handle_call({:get_logs, :short}, _, state), do: {:reply, Enum.take(state, 10), state}

  @impl true
  def handle_call({:get_logs, :long}, _, state), do: {:reply, state, state}
end
