defmodule Nwone.GameMap do
  @moduledoc """
  Map generation and map objects mapping logic
  """

  @default_map_size 10

  defstruct size: @default_map_size, tiles: []

  alias Nwone.GameMap
  alias Nwone.GameMap.Tile

  def generate(game_map_size \\ @default_map_size) do
    tiles_num = trunc(:math.pow(game_map_size, 2) - 1)

    tiles =
      for n <- 0..tiles_num do
        row = div(n, game_map_size) + 1
        column = rem(n, game_map_size) + 1

        %Tile{
          row: row,
          col: column,
          index: n,
          blocked: blocked_tile?(row, column, game_map_size),
          first_in_row: column == 1,
          last_in_row: column == game_map_size
        }
      end

    %GameMap{tiles: tiles}
  end

  def update(game_map, players) do
    Enum.reduce(players, game_map, fn player, game_map ->
      move_player(game_map, player, player.position, player.position)
    end)
  end

  def put_player(game_map, player, index) do
    tile = Enum.at(game_map.tiles, index)

    %GameMap{
      game_map
      | tiles:
          List.replace_at(
            game_map.tiles,
            index,
            %Tile{tile | players: [player | tile.players]}
          )
    }
  end

  def move_player(game_map, player, from_index, to_index) do
    game_map
    |> remove_player(player, from_index)
    |> put_player(player, to_index)
  end

  def remove_player(game_map, player, index) do
    tile = Enum.at(game_map.tiles, index)
    player_index = find_player(tile.players, player)

    %GameMap{
      game_map
      | tiles:
          List.replace_at(
            game_map.tiles,
            index,
            %Tile{tile | players: List.delete_at(tile.players, player_index)}
          )
    }
  end

  def free_tiles(game_map) do
    game_map.tiles
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _index} ->
      !tile.blocked && length(tile.players) == 0
    end)
  end

  def movable_tiles(game_map) do
    game_map.tiles
    |> Enum.with_index()
    |> Enum.filter(fn {tile, _index} -> !tile.blocked end)
  end

  defp blocked_tile?(row, column, game_map_size) do
    position = {row, column}
    border?(position, game_map_size) || blocking_object?(position)
  end

  defp border?(position, game_map_size) do
    case position do
      {1, _} -> true
      {_, 1} -> true
      {^game_map_size, _} -> true
      {_, ^game_map_size} -> true
      _ -> false
    end
  end

  defp blocking_object?(position) do
    case position do
      {5, 2} -> true
      {5, 4} -> true
      {5, 5} -> true
      {5, 6} -> true
      {5, 7} -> true
      {6, 5} -> true
      {7, 5} -> true
      {8, 5} -> true
      _ -> false
    end
  end

  defp find_player(players, player) do
    Enum.find_index(players, fn p -> p.pid == player.pid end)
  end

end
