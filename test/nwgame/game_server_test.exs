defmodule Nwgame.GameServerTest do
  use ExUnit.Case

  alias Nwgame.{GameServer, GameMap, Player}

  @server_name :test_server

  describe "start_link/1" do
    test "spawns a process" do
      assert {:ok, _pid} = GameServer.start_link(@server_name)
    end
  end

  describe "get_map/1" do
    test "return current map on given game server" do
      assert {:ok, _pid} = GameServer.start_link(@server_name)
      assert %GameMap{} = GameServer.get_map(@server_name)
    end
  end

  describe "join/1" do
    test "joins player to given server" do
      assert {:ok, _pid} = GameServer.start_link(@server_name)

      assert {%GameMap{}, %Player{}} =
               GameServer.join(@server_name, Player.new(:test, @server_name))
    end
  end

  describe "move_player/3" do
    test "moves player in chossen direction" do
      new_player = Player.new(:test, @server_name)

      assert {:ok, _pid} = GameServer.start_link(@server_name)

      assert {%GameMap{}, %Player{}} = GameServer.move_player(@server_name, new_player, :ArrowUp)

      assert {%GameMap{}, %Player{}} =
               GameServer.move_player(@server_name, new_player, :ArrowDown)

      assert {%GameMap{}, %Player{}} =
               GameServer.move_player(@server_name, new_player, :ArrowLeft)

      assert {%GameMap{}, %Player{}} =
               GameServer.move_player(@server_name, new_player, :ArrowRight)
    end
  end

  describe "hit/2" do
    test "hits map tiles and players on them around given player" do
      assert {:ok, _pid} = GameServer.start_link(@server_name)
      assert {_map, player} = GameServer.join(@server_name, Player.new(:test, @server_name))
      assert {_map, player2} = GameServer.join(@server_name, Player.new(:test2, @server_name))
      assert {%GameMap{}, ^player} = GameServer.hit(@server_name, player)
    end
  end

  describe "remove_player/2" do
    test "removes player from map" do
      assert {:ok, _pid} = GameServer.start_link(@server_name)
      assert {_map, player} = GameServer.join(@server_name, Player.new(:test, @server_name))
      assert :ok = GameServer.remove_player(@server_name, player)
    end
  end
end
