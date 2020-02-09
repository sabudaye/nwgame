defmodule Nwone.Player do
  @moduledoc """
  Player struct
  """

  alias __MODULE__

  defstruct name: "",
            state: :alive,
            position: 0,
            pid: nil,
            game_server: nil

  def change_position(player, new_position) do
    %Player{player | position: new_position}
  end

  def die(player) do
    %Player{player | state: :dead}
  end

  def resurect(player) do
    %Player{player | state: :alive}
  end
end
