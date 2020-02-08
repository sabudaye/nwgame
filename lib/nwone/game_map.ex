defmodule Nwone.GameMap do
  @moduledoc """
  Map generation and map objects mapping logic
  """

  @default_map_size 10

  defstruct size: @default_map_size, tiles: []

  alias Nwone.GameMap.Tile

  def generate(game_map_size \\ @default_map_size) do
    tiles_num = trunc(:math.pow(game_map_size, 2) - 1)
    tiles = for n <- 0..tiles_num do
      row = div(n, game_map_size) + 1
      column = rem(n, game_map_size) + 1
      %Tile{
        row: row,
        col: column,
        blocked: blocked?(row, column),
        first_in_row: column == 1,
        last_in_row: column == game_map_size
      }
    end
    %Nwone.GameMap{tiles: tiles}
  end

  defp blocked?(row, column) do
    case {row, column} do
      # borders
      {1, _} -> true
      {_, 1} -> true
      {@default_map_size, _} -> true
      {_, @default_map_size} -> true
      # blocked tiles
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
