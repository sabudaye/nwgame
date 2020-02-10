defmodule Nwone.Player do
  @moduledoc """
  Player struct
  """

  alias __MODULE__

  @registry Nwone.PlayerRegistry

  defstruct name: "",
            state: :alive,
            position: 0,
            pid: nil,
            game_server: nil,
            timer: nil

  def new(name, game_server) do
    %Player{
      name: name,
      pid: via_tuple(name),
      game_server: game_server
    }
  end

  def change_position(player, new_position) do
    %Player{player | position: new_position}
  end

  def die(player) do
    %Player{player | state: :dead}
  end

  def resurect(player) do
    %Player{player | state: :alive}
  end

  defp via_tuple(player_name),
    do: {:via, Registry, {@registry, {__MODULE__, player_name}}}
end
