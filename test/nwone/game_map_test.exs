defmodule Nwone.GameMapTest do
  use ExUnit.Case, async: true

  alias Nwone.GameMap
  alias Nwone.GameMap.Tile
  alias Nwone.Player

  describe "generate/1" do
    test "generates map with tiles" do
      %GameMap{tiles: tiles} = GameMap.generate()
      assert Enum.count(tiles) == 100
      assert hd(tiles) == %Tile{row: 1, col: 1, blocked: true, last_in_row: false}
      assert Enum.at(tiles, 9) == %Tile{row: 1, col: 10, index: 9, blocked: true, first_in_row: false}

      assert Enum.at(tiles, 12) == %Tile{
               row: 2,
               col: 3,
               index: 12,
               blocked: false,
               last_in_row: false,
               first_in_row: false
             }

      assert Enum.at(tiles, 41).blocked
      assert List.last(tiles) == %Tile{row: 10, col: 10, index: 99, blocked: true, first_in_row: false}
    end
  end

  describe "put_player/3" do
    test "places player on given tile" do
      map = GameMap.generate()
      %GameMap{tiles: tiles} = GameMap.put_player(map, %Player{name: "test"}, 13)
      tile = Enum.find(tiles, fn tile -> tile.players != [] end)
      assert tile.players == [%Player{name: "test"}]
    end
  end

  describe "remove_player/3" do
    test "removes player from given tile" do
      map = GameMap.generate()
      map = GameMap.put_player(map, %Player{name: "test"}, 13)

      tile = Enum.find(map.tiles, fn tile -> tile.players != [] end)
      assert tile.players == [%Player{name: "test"}]

      map = GameMap.remove_player(map, %Player{name: "test"}, 13)

      tile = Enum.find(map.tiles, fn tile -> tile.players != [] end)
      assert tile == nil
    end
  end

  describe "free_tiles/1" do
    test "returns list free tiles with indexs in tuples" do
      map = GameMap.generate()
      result = GameMap.free_tiles(map)

      {%Tile{}, 11} = hd(result)
      assert Enum.count(result) == 56
    end
  end
end
