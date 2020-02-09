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
    tiles = for n <- 0..tiles_num do
      row = div(n, game_map_size) + 1
      column = rem(n, game_map_size) + 1
      %Tile{
        row: row,
        col: column,
        blocked: blocked_tile?(row, column, game_map_size),
        first_in_row: column == 1,
        last_in_row: column == game_map_size
      }
    end
    %GameMap{tiles: tiles}
  end

  def put_player(game_map, player_name) do
    {tile, index} = game_map
      |> free_tiles()
      |> Enum.random()

    %GameMap{game_map | tiles: List.replace_at(
      game_map.tiles,
      index,
      %Tile{tile | players: [player_name | tile.players]}
    )}
  end

  defp free_tiles(game_map) do
    game_map.tiles
    |> Enum.with_index()
    |> Enum.filter(fn ({tile, _index}) ->
      !tile.blocked && length(tile.players) == 0
    end)
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
end
