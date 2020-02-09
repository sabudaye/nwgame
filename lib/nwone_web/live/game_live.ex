defmodule NwoneWeb.GameLive do
  use Phoenix.LiveView

  alias Nwone.GameServer

  def render(assigns) do
    NwoneWeb.GameView.render("game.html", assigns)
  end

  def mount(params, socket) do
    socket =
      socket
      |> assign(
        name: params["name"],
        map: GameServer.get_map(),
        player_pid: params["player_pid"]
      )
    # IO.inspect GameServer.get_map().tiles |> Enum.filter(fn x -> length(x.players) != 0 end)
    {:ok, socket}
  end
end
