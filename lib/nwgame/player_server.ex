defmodule Nwgame.PlayerServer do
  @moduledoc """
  Genserver to hold a players state within a process.
  """
  use GenServer
  require Logger
  alias Nwgame.GameServer
  alias Nwgame.Player
  alias NwgameWeb.GameLive

  @timeout :timer.seconds(20)
  @registry Nwgame.PlayerRegistry
  @supervisor Nwgame.PlayerSupervisor
  @resurect_time 5000

  # API

  def start(player_name, game_server) do
    player = Player.new(player_name, game_server)
    player = %Player{player | timer: start_timer()}

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

  def move(pid, move) do
    GenServer.call(pid, move)
  end

  def die(pid, attacker) do
    GenServer.cast(pid, {:die, attacker})
  end

  def stop_all() do
    @supervisor
    |> Supervisor.which_children()
    |> Enum.map(&elem(&1, 1))
    |> Enum.each(&DynamicSupervisor.terminate_child(@supervisor, &1))
  end

  # Callbacks

  def init(%Player{name: player_name, game_server: game_server} = player) do
    Logger.info("Starting player process for #{player_name}")
    {_, player} = GameServer.join(game_server, player)
    GameLive.notify(GameLive.topic())
    {:ok, %Player{player | timer: start_timer()}, @timeout}
  end

  def handle_call(:get_player, _from, player) do
    {:reply, player, player}
  end

  def handle_call(_action, _from, %Player{state: :dead} = player) do
    map = GameServer.get_map(player.game_server)
    {:reply, {map, player}, player}
  end

  def handle_call(:Space, _from, %Player{game_server: game_server, timer: ref} = player) do
    {map, player} = GameServer.hit(game_server, player)
    {:reply, {map, player}, %Player{player | timer: restart_timer(ref)}}
  end

  def handle_call(move, _from, %Player{game_server: game_server, timer: ref} = player) do
    {map, player} = GameServer.move_player(game_server, player, move)
    {:reply, {map, player}, %Player{player | timer: restart_timer(ref)}}
  end

  def handle_cast({:die, attacker}, player) do
    player = Player.die(player)
    Logger.info("Player #{player.name} died from attack of #{attacker.name}")
    GameLive.notify(GameLive.topic())
    :timer.send_after(@resurect_time, self(), :resurect)
    {:noreply, player}
  end

  def handle_info(:resurect, player) do
    player = Player.resurect(player)
    GameServer.remove_player(player.game_server, player)

    {:stop, {:shutdown, :resurect}, player}
  end

  def handle_info(:timeout, player) do
    GameServer.remove_player(player.game_server, player)
    {:stop, {:shutdown, :timeout}, player}
  end

  def terminate({:shutdown, :resurect}, %Player{name: player_name}) do
    Logger.info("Player #{player_name} resurected")
    :ok
  end

  def terminate({:shutdown, :timeout}, %Player{name: player_name}) do
    Logger.info("Terminate (Timeout) running for #{player_name}")
    :ok
  end

  def terminate(_reason, %Player{name: player_name}) do
    Logger.info("Strange termination for [#{player_name}].")
    :ok
  end

  def start_timer() do
    {:ok, ref} = :timer.send_after(@timeout, self(), :timeout)
    ref
  end

  def restart_timer(ref) do
    :timer.cancel(ref)
    start_timer()
  end
end
