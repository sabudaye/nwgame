defmodule Nwone.GameMap.Tile do
  @moduledoc """
  Game map tile struct
  """

  defstruct blocked: true,
    row: 1,
    col: 1,
    players: [],
    first_in_row: true,
    last_in_row: true
end
