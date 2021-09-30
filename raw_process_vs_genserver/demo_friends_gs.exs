defmodule DemoFriendsGS do
  use GenServer

  def start(args \\ []) do
    GenServer.start(__MODULE__, args)
  end

  def retrieve_friends(pid) do
    GenServer.call(pid, :retrieve_friends)
  end

  def add_friend(pid, name) do
    GenServer.cast(pid, {:add_friend, name})
  end

  @impl true
  def init(_args) do
    initial_state = %{friends: []}
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:retrieve_friends, _from, state) do
    {:reply, state.friends, state}
  end

  @impl true
  def handle_cast({:add_friend, name}, state) do
    new_state = %{state | friends: [name | state.friends]}
    {:noreply, new_state}
  end
end
