defmodule Nwone.PlayerServer do
  @moduledoc """
  Genserver to hold a players state within a process.
  """
  use GenServer
  require Logger
  alias Nwone.GameServer

  @timeout :timer.hours(1)
  @registry Nwone.PlayerRegistry
  @supervisor Nwone.PlayerSupervisor

  # API

  def start(player_name, game_server) do
    opts = [
      player_name: player_name,
      name: via_tuple(player_name),
      game_server: game_server
    ]

    DynamicSupervisor.start_child(@supervisor, {__MODULE__, opts})
  end

  def lookup(player_name) do
    case Registry.lookup(@registry, player_name) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def via_tuple(player_name),
    do: {:via, Registry, {@registry, {__MODULE__, player_name}}}

  # Callbacks

  def init([player_name: player_name, name: _, game_server: game_server] = opts) do
    Logger.info("Starting player process for #{player_name}")
    GameServer.join(game_server, player_name)
    {:ok, Enum.into(opts, %{}), @timeout}
  end

  def init([player_name: player_name, game_server: game_server] = opts) do
    Logger.info("Starting player process for #{player_name}")
    GameServer.join(game_server, player_name)
    {:ok, Enum.into(opts, %{}), @timeout}
  end

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end

  def terminate({:shutdown, :timeout}, %{player_name: player_name}) do
    Logger.info("Terminate (Timeout) running for #{player_name}")
    :ok
  end

  def terminate(_reason, %{player_name: player_name}) do
    Logger.info("Strange termination for [#{player_name}].")
    :ok
  end
end
