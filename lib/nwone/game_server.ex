defmodule Nwone.GameServer do
  @moduledoc """
  Server to maintain game state
  """
  use GenServer, restart: :transient

  alias Nwone.GameMap
  require Logger
  @registry Nwone.PlayerRegistry

  # API

  def start_link(_) do
    GenServer.start_link(__MODULE__, GameMap.generate(), name: __MODULE__)
  end

  def get_map() do
    GenServer.call(__MODULE__, :get_map)
  end

  def join(game_server, player_name) do
    GenServer.call(game_server, {:join, player_name})
  end

  # Callbacks

  def init(map) do
    {:ok, map}
  end

  def handle_call(:get_map, _from, map) do
    {:reply, map, map}
  end

  def handle_call({:join, player_name}, _from, map) do
    case Registry.lookup(@registry, player_name) do
      [{_pid, _}] ->
        {:reply, map, map}
      [] ->
        new_map = GameMap.put_player(map, player_name)
        {:reply, new_map, new_map}
    end
  end
end
