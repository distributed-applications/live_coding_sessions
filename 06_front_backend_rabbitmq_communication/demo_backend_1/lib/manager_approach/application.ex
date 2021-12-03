defmodule ManagerApproach.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: ManagerApproach.Worker.start_link(arg)
      # {ManagerApproach.Worker, arg}
      {Registry, keys: :unique, name: ManagerApproach.MyRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: ManagerApproach.GarbageCanDynSup},
      {ManagerApproach.GarbageCanManager, []},
      ManagerApproach.WebserverPublisher,
      ManagerApproach.ManagerOperationsConsumer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ManagerApproach.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
