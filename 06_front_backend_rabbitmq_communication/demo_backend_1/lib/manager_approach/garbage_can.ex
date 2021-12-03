defmodule ManagerApproach.GarbageCan do
  use GenServer

  require Logger

  @me __MODULE__
  defstruct percentage: 0, personal_id: nil

  # ### #
  # API #
  # ### #

  def start_link(args) do
    # Should be registered in the registry since there can be a dynamic amount of
    #   garbage cans.
    can_id = args[:can_id] || raise "no garbage can id key found \":can_id\""
    GenServer.start_link(@me, args, name: via_tuple(can_id))
  end

  def empty(can_id) do
    can_id
    |> via_tuple()
    |> GenServer.call(:empty)
  end

  # ######### #
  # CALLBACKS #
  # ######### #

  @impl true
  def init(args) do
    :timer.send_interval(6000, :add_garbage)
    {:ok, %@me{personal_id: args[:can_id]}, {:continue, :report}}
  end

  @impl true
  def handle_call(:empty, _from, %@me{} = state) do
    Logger.debug("#{inspect(self())}: I'm being emptied!")
    {:reply, :ok, %{state | percentage: 0}, {:continue, :report}}
  end

  @impl true
  def handle_info(:add_garbage, %@me{} = state) do
    {:noreply, %{state | percentage: state.percentage + 10}, {:continue, :report}}
  end

  @impl true
  def handle_continue(:report, %@me{} = state) do
    ManagerApproach.GarbageCanManager.report_garbage_level(state.personal_id, state.percentage)
    {:noreply, state}
  end

  # ######################## #
  # PRIVATE HELPER FUNCTIONS #
  # ######################## #

  defp via_tuple(can_id) do
    {:via, Registry, {ManagerApproach.MyRegistry, {:garbage_can, can_id}}}
  end
end
