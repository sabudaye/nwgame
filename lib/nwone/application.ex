defmodule Nwone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Nwone.PlayerRegistry},
      {DynamicSupervisor, name: Nwone.PlayerSupervisor, strategy: :one_for_one},
      NwoneWeb.Endpoint,
      Nwone.GameServer
    ]

    :ets.new(:players, [:public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nwone.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NwoneWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
