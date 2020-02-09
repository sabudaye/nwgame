defmodule NwoneWeb.GameController do
  use NwoneWeb, :controller

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def start(conn, params) do
    conn
    |> put_session(:name, params["name"])
    |> redirect(to: Routes.game_path(conn, :game))
  end

  def game(conn, params) do
    name = params["name"] || get_session(conn, :name)
    unless(name, do: redirect(conn, to: Routes.game_path(conn, :login)))

    player = Nwone.PlayerServer.start(name, Nwone.GameServer)

    live_render(conn, NwoneWeb.GameLive,
      session: %{"player" => player, "player_pid" => player.pid}
    )
  end
end
