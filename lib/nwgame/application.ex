defmodule Nwgame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Nwgame.PlayerRegistry},
      {DynamicSupervisor, name: Nwgame.PlayerSupervisor, strategy: :one_for_one},
      NwgameWeb.Endpoint,
      Nwgame.GameServer
    ]

    :ets.new(:players, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nwgame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NwgameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
