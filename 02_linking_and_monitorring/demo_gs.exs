defmodule FactorialCalculator do
  def run(%{number: n}) when is_integer(n) and n >= 0 do
    calculate_factorial(n)
  end

  def calculate_factorial(n), do: factorial(n, 1)

  defp factorial(0, acc), do: acc
  defp factorial(1, acc), do: acc
  defp factorial(n, acc), do: factorial(n - 1, acc * n)
end

defmodule DistributedFactorialsManager do
  use GenServer
  @me __MODULE__

  defstruct tasks: %{}

  def start_link(args \\ []), do: GenServer.start_link(@me, args, name: @me)
  def calculate(n), do: GenServer.call(@me, {:calculate, n})

  def init(_args), do: {:ok, %@me{}}

  def handle_call({:calculate, n}, from, state) do
    task = %Task{ref: ref} = Task.async(FactorialCalculator, :run, [%{number: n}])

    new_tasks = Map.put(state.tasks, ref, %{task: task, from: from})
    {:noreply, %{state | tasks: new_tasks}}
  end

  # The task completed successfully
  def handle_info({ref, answer}, %@me{} = state) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])

    new_state_tasks =
      case Map.pop(state.tasks, ref) do
        {nil, state_tasks} ->
          state_tasks

        {%{task: _unused_task, from: from}, new_state_tasks} ->
          GenServer.reply(from, answer)

          new_state_tasks
      end

    {:noreply, %{state | tasks: new_state_tasks}}
  end

  # The task failed
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    require IEx
    IEx.pry()
    {:noreply, state}
  end
end

DistributedFactorialsManager.start_link()
DistributedFactorialsManager.calculate(5)

max = 4500

sequential = fn -> Enum.map(1..max, &DistributedFactorialsManager.calculate/1) end

parallel = fn ->
  tasks =
    Enum.map(1..max, fn n -> Task.async(fn -> DistributedFactorialsManager.calculate(n) end) end)
    |> Task.yield_many(:infinity)
end

defmodule Benchmark do
  def measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Kernel./(1_000_000)
  end
end

Benchmark.measure(sequential)
Benchmark.measure(parallel)
