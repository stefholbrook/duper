defmodule Duper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Duper.Worker.start_link(arg)
      # {Duper.Worker, arg}
      Duper.Results,
      # tuple so we can pass in the root of the tree to be searched as a parameter
      # "." is current working directory
      {Duper.PathFinder, "."}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Duper.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
