defmodule Nwone.GameMapTest do
  use ExUnit.Case, async: true

  alias Nwone.GameMap
  alias Nwone.GameMap.Tile

  describe "generate/1" do
    test "generates map with tiles" do
      %GameMap{tiles: tiles} = GameMap.generate()
      assert Enum.count(tiles) == 100
      assert hd(tiles) == %Tile{row: 1, col: 1, blocked: true, last_in_row: false}
      assert Enum.at(tiles, 9) == %Tile{row: 1, col: 10, blocked: true, first_in_row: false}
      assert Enum.at(tiles, 12) == %Tile{row: 2, col: 3, blocked: false, last_in_row: false, first_in_row: false}
      assert Enum.at(tiles, 41).blocked
      assert List.last(tiles) == %Tile{row: 10, col: 10, blocked: true, first_in_row: false}
    end
  end

  describe "put_player/2" do
    test "places player on random free tile" do
      map = GameMap.generate()
      %GameMap{tiles: tiles} = GameMap.put_player(map, "test player")
      tile = Enum.find(tiles, fn tile -> tile.players != [] end)
      assert tile.players == ["test player"]
    end
  end
end
