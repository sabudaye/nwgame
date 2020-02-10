defmodule NwgameWeb.GameView do
  use NwgameWeb, :view

  def tile_class(tile, player) do
    class = ""

    class =
      if tile.players != [] do
        if tile.index == player.position do
          maybe_dead(class <> " player", player)
        else
          maybe_dead(class <> " enemy", alive_first(tile.players))
        end
      else
        class
      end

    class = if(tile.blocked, do: class <> " blocked", else: class)
    if(tile.last_in_row, do: class <> " last_in_row", else: class)
  end

  def player_name(tile, player) do
    if tile.players != [] do
      if tile.index == player.position do
        player.name
      else
        alive_first(tile.players).name
      end
    else
      ""
    end
  end

  def alive_first(players) do
    res = Enum.filter(players, fn p -> p.state == :alive end)

    if res == [] do
      hd(players)
    else
      hd(res)
    end
  end

  def maybe_dead(class, player) do
    if(player.state == :dead, do: class <> " dead", else: class)
  end
end
