defmodule TspSolver.Application do
  @moduledoc """
  The main application module for TspSolver.

  Defines the supervision tree and starts the application.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = []

    opts = [strategy: :one_for_one, name: TspSolver.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
