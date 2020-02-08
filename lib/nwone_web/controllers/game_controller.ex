defmodule NwoneWeb.GameController do
  use NwoneWeb, :controller

  def login(conn, params) do
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

    live_render(conn, NwoneWeb.GameLive, session: %{"name" => name})
  end
end
