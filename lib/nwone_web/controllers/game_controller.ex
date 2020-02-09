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

    player_pid = case Nwone.PlayerServer.start(name, Nwone.GameServer) do
      {:ok, player_pid} -> player_pid
      {:error, {:already_started, player_pid}} -> player_pid
    end

    live_render(conn, NwoneWeb.GameLive, session: %{"name" => name, "player_pid" => player_pid})
  end
end
