defmodule Nwone.GameServer do
  @moduledoc """
  Server to maintain game state
  """
  use GenServer, restart: :transient

  alias Nwone.GameMap
  alias Nwone.Player
  alias Nwone.PlayerServer
  require Logger

  @timeout :timer.minutes(10)

  # API

  def start_link([]) do
    GenServer.start_link(__MODULE__, GameMap.generate(), name: __MODULE__)
  end

  def start_link(name) do
    GenServer.start_link(__MODULE__, GameMap.generate(), name: name)
  end

  def get_map() do
    GenServer.call(__MODULE__, :get_map)
  end

  def get_map(game_server) do
    GenServer.call(game_server, :get_map)
  end

  def join(game_server, player) do
    GenServer.call(game_server, {:join, player})
  end

  def move_player(game_server, player, move) do
    GenServer.call(game_server, {:move_player, player, move})
  end

  def hit(game_server, player) do
    GenServer.call(game_server, {:hit, player})
  end

  def resurection(game_server, player) do
    GenServer.cast(game_server, {:resurection, player})
  end

  def remove_player(game_server, player) do
    GenServer.cast(game_server, {:remove_player, player})
  end

  # Callbacks

  def init(map) do
    {:ok, %{map: map, players: [], timer: start_timer()}}
  end

  def handle_call(:get_map, _from, %{map: map} = state) do
    {:reply, map, state}
  end

  def handle_call({:join, player}, _from, %{map: map, players: players} = state) do
    case PlayerServer.lookup(player.pid) do
      [{_pid, _}] ->
        {:reply, map, state}

      _ ->
        {_tile, index} =
          map
          |> GameMap.free_tiles()
          |> Enum.random()

        player = Player.change_position(player, index)
        new_map = GameMap.put_player(map, player, index)

        new_state =
          state
          |> put_in([:map], new_map)
          |> put_in([:players], [player | players])

        Logger.info("Player #{player.name} joined to the game, poisition: #{player.position}")
        {:reply, {new_map, player}, new_state}
    end
  end

  def handle_call({:hit, player}, _from, %{map: map, players: players} = state) do
    poh = positions_on_hit(player.position, map.size)
    player_index = find_player(players, player)
    players = update_hitted_players(player, players, poh)
    new_map = GameMap.update(map, players)

    new_state =
      state
      |> put_in([:map], new_map)
      |> put_in([:players], replace_player(player_index, players, player))

    Logger.info("Player #{player.name} attacked from #{player.position}")
    {:reply, {map, player}, new_state}
  end

  def handle_call({:move_player, player, move}, _from, %{map: map, players: players, timer: ref} = state) do
    player_index = find_player(players, player)

    {new_map, player} = do_move_player(player_index, map, player, move)

    new_state =
      state
      |> put_in([:map], new_map)
      |> put_in([:players], replace_player(player_index, players, player))
      |> put_in([:timer], restart_timer(ref))

    {:reply, {new_map, player}, new_state}
  end

  def handle_cast({:remove_player, _}, %{players: []} = state) do
    {:noreply, state}
  end

  def handle_cast({:remove_player, player}, %{map: map, players: players} = state) do
    player_index = find_player(players, player)

    new_map = GameMap.remove_player(map, player, player.position)

    new_state =
      state
      |> put_in([:map], new_map)
      |> put_in([:players], List.delete_at(players, player_index))

    Logger.info("Player #{player.name} removed")
    {:noreply, new_state}
  end


  def handle_cast({:resurection, player}, %{players: players} = state) do
    player_index = find_player(players, player)

    new_state =
      state
      |> put_in([:players], replace_player(player_index, players, player))

    {:noreply, new_state}
  end

  def handle_info(:cleanup, _state) do
    PlayerServer.stop_all()
    {:noreply, %{map: GameMap.generate(), players: [], timer: start_timer()}}
  end

  # Private functions

  defp find_player(players, player) do
    Enum.find_index(players, fn p -> p.pid == player.pid end)
  end

  defp update_hitted_players(attacker, players, hitted_positions) do
    Enum.map(players, fn player ->
      if player.position in hitted_positions && player.pid != attacker.pid do
        PlayerServer.die(player.pid, attacker)
        Player.die(player)
      else
        player
      end
    end)
  end

  defp replace_player(nil, players, _player), do: players

  defp replace_player(index, players, player) do
    List.replace_at(players, index, player)
  end

  defp do_move_player(nil, map, player, _), do: {map, player}

  defp do_move_player(_index, map, player, move) do
    tiles_with_index = GameMap.movable_tiles(map)

    new_position = try_get_new_position(map.size, tiles_with_index, player.position, move)
    new_map = GameMap.move_player(map, player, player.position, new_position)

    player = Player.change_position(player, new_position)

    {new_map, player}
  end

  defp try_get_new_position(map_size, tiles, old_position, :ArrowUp) do
    result = Enum.find(tiles, fn {_tile, index} -> index == old_position - map_size end)
    if(result, do: old_position - map_size, else: old_position)
  end

  defp try_get_new_position(map_size, tiles, old_position, :ArrowDown) do
    result = Enum.find(tiles, fn {_tile, index} -> index == old_position + map_size end)
    if(result, do: old_position + map_size, else: old_position)
  end

  defp try_get_new_position(_map_size, tiles, old_position, :ArrowLeft) do
    result = Enum.find(tiles, fn {_tile, index} -> index == old_position - 1 end)
    if(result, do: old_position - 1, else: old_position)
  end

  defp try_get_new_position(_map_size, tiles, old_position, :ArrowRight) do
    result = Enum.find(tiles, fn {_tile, index} -> index == old_position + 1 end)
    if(result, do: old_position + 1, else: old_position)
  end

  defp positions_on_hit(position, map_size) do
    [
      position,
      position - 1,
      position + 1,
      position - map_size,
      position - map_size - 1,
      position - map_size + 1,
      position + map_size,
      position + map_size - 1,
      position + map_size + 1
    ]
  end

  def start_timer() do
    {:ok, ref} = :timer.send_after(@timeout, self(), :cleanup)
    ref
  end

  def restart_timer(ref) do
    :timer.cancel(ref)
    start_timer()
  end
end
