defmodule NwoneWeb.GameView do
  use NwoneWeb, :view

  def tile_class(tile, name) do
    class = ""
    class = if tile.players != [] do
      if Enum.member?(tile.players, name) do
        class <> " player"
      else
        class <> " enemy"
      end
    else
      class
    end
    class = if(tile.blocked, do: class <> " blocked", else: class)
    if(tile.last_in_row, do: class <> " last_in_row", else: class)
  end

  def player_name(tile, name) do
    if tile.players != [] do
      if Enum.member?(tile.players, name) do
        name
      else
        hd(tile.players)
      end
    else
      ""
    end
  end
end
