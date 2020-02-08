defmodule Nwone.GameMapTest do
  use ExUnit.Case, async: true

  alias Nwone.GameMap
  alias Nwone.GameMap.Tile

  describe "generate/1" do
    test "generates map with tiles" do
      %GameMap{tiles: tiles} = GameMap.generate()
      assert Enum.count(tiles) == 100
      assert hd(tiles) == %Tile{row: 1, col: 1, blocked: true}
      assert Enum.at(tiles, 9) == %Tile{row: 1, col: 10, blocked: true}
      assert Enum.at(tiles, 12) == %Tile{row: 2, col: 3, blocked: false}
      assert Enum.at(tiles, 41).blocked
      assert List.last(tiles) == %Tile{row: 10, col: 10, blocked: true}
    end
  end
end
