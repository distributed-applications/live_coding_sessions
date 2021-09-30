defmodule DemoFriends do
  # API
  def start(args \\ []) do
    spawn(__MODULE__, :private_init, [args])
  end

  def retrieve_friends(pid) do
    send(pid, {:retrieve_friends, self()})

    receive do
      {:reply_retrieve_friends, friends} ->
        friends
    after
      5000 -> {:error, :timeout}
    end
  end

  def add_friends(pid, name) do
    send(pid, {:add_friend, name})
  end

  # Callbacks
  def private_init(_args) do
    initial_state = %{friends: []}
    loop(initial_state)
  end

  def loop(state) do
    receive do
      {:retrieve_friends, pid} ->
        send(pid, {:reply_retrieve_friends, state.friends})
        loop(state)

      {:add_friend, name} ->
        new_state = %{state | friends: [name | state.friends]}
        loop(new_state)
    end
  end
end
