defmodule Nwone.PlayerServer do
  @moduledoc """
  Genserver to hold a players state within a process.
  """
  use GenServer
  require Logger
  alias Nwone.GameServer
  alias Nwone.Player
  alias NwoneWeb.GameLive

  @timeout :timer.hours(1)
  @registry Nwone.PlayerRegistry
  @supervisor Nwone.PlayerSupervisor
  @resurect_time 5000

  # API

  def start(player_name, game_server) do
    player = %Player{
      name: player_name,
      pid: via_tuple(player_name),
      game_server: game_server
    }

    _ = DynamicSupervisor.start_child(@supervisor, {__MODULE__, player})
    get_player(player.pid)
  end

  def get_player(player_pid) do
    GenServer.call(player_pid, :get_player)
  end

  def lookup(player_pid) do
    case Registry.lookup(@registry, player_pid) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  def start_link(%Player{} = player) do
    GenServer.start_link(__MODULE__, player, name: player.pid)
  end

  def via_tuple(player_name),
    do: {:via, Registry, {@registry, {__MODULE__, player_name}}}

  def move(pid, move) do
    GenServer.call(pid, move)
  end

  def die(pid, attacker) do
    GenServer.cast(pid, {:die, attacker})
  end

  # Callbacks

  def init(%Player{name: player_name, game_server: game_server} = player) do
    Logger.info("Starting player process for #{player_name}")
    {_, player} = GameServer.join(game_server, player)
    {:ok, player, @timeout}
  end

  def handle_call(:get_player, _from, player) do
    {:reply, player, player}
  end

  def handle_call(_action, _from, %Player{state: :dead} = player) do
    map = GameServer.get_map(player.game_server)
    {:reply, {map, player}, player}
  end

  def handle_call(:Space, _from, %Player{game_server: game_server} = player) do
    {map, player} = GameServer.hit(game_server, player)
    {:reply, {map, player}, player}
  end

  def handle_call(move, _from, %Player{game_server: game_server} = player) do
    {map, player} = GameServer.move_player(game_server, player, move)
    {:reply, {map, player}, player}
  end

  def handle_cast({:die, atacker}, player) do
    player = Player.die(player)
    Logger.info("Player #{player.name} died from attack of #{atacker.name}")
    GameLive.notify(GameLive.topic())
    :timer.send_after(@resurect_time, self(), :resurect)
    {:noreply, player}
  end

  def handle_info(:resurect, player) do
    player = Player.resurect(player)
    GameServer.resurection(player.game_server, player)
    GameLive.notify(GameLive.topic())
    Logger.info("Player #{player.name} resurected")
    {:noreply, player}
  end

  def handle_info(:timeout, player) do
    {:stop, {:shutdown, :timeout}, player}
  end

  def terminate({:shutdown, :timeout}, %Player{name: player_name}) do
    Logger.info("Terminate (Timeout) running for #{player_name}")
    :ok
  end

  def terminate(_reason, %Player{name: player_name}) do
    Logger.info("Strange termination for [#{player_name}].")
    :ok
  end
end
