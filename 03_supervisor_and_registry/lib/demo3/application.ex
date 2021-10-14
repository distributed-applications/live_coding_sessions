defmodule Demo3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Demo3.Worker.start_link(arg)
      # {Demo3.Worker, arg}
      Demo3.Part1.GeneralChatRoomV1,
      Demo3.Part2.SubApplication
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Demo3.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
