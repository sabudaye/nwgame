defmodule NwoneWeb.GameLive do
  use Phoenix.LiveView

  alias Nwone.GameMap

  def render(assigns) do
    NwoneWeb.GameView.render("game.html", assigns)
  end

  def mount(%{"name" => name}, socket) do
    {:ok, assign(socket, name: name, map: GameMap.generate())}
  end
end
