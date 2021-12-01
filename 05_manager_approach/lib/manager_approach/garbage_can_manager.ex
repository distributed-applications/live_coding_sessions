defmodule ManagerApproach.GarbageCanManager do
  use GenServer

  alias ManagerApproach.{GarbageCan, GarbageCanDynSup}

  @me __MODULE__
  defstruct garbage_cans: %{}

  # ### #
  # API #
  # ### #

  def start_link(args) do
    # This process can be name registered "normally" without a registry!
    # It's part of the static part of the tree and should be callable regardless of the
    #   registry
    GenServer.start_link(@me, args, name: @me)
  end

  def add_garbage_can(can_id) do
    GenServer.call(@me, {:place_garbage_can, can_id})
  end

  def report_garbage_level(can_id, percentage) when is_integer(percentage) and percentage >= 0 do
    GenServer.cast(@me, {:garbage_update, can_id, percentage})
  end

  # ######### #
  # CALLBACKS #
  # ######### #

  @impl true
  def init(_args), do: {:ok, %@me{}}

  @impl true
  def handle_cast({:garbage_update, can_id, percentage}, %@me{} = state) do
    new_garbage_cans = Map.put(state.garbage_cans, can_id, percentage)
    new_state = %{state | garbage_cans: new_garbage_cans}

    case percentage >= 100 do
      false -> {:noreply, new_state}
      true -> {:noreply, new_state, {:continue, {:empty_can, can_id}}}
    end
  end

  @impl true
  def handle_call({:place_garbage_can, can_id}, _from, %@me{} = state) do
    case Map.has_key?(state.garbage_cans, can_id) do
      true ->
        {:reply, {:error, :already_exists}, state}

      false ->
        response = DynamicSupervisor.start_child(GarbageCanDynSup, {GarbageCan, [can_id: can_id]})
        new_garbage_cans = Map.put_new(state.garbage_cans, can_id, :not_initialized)
        {:reply, response, %{state | garbage_cans: new_garbage_cans}}
    end
  end

  @impl true
  def handle_continue({:empty_can, can_id}, %@me{} = state) do
    GarbageCan.empty(can_id)
    {:noreply, state}
  end
end
