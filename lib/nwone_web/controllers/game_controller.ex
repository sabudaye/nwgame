defmodule NwoneWeb.GameController do
  use NwoneWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.game_path(conn, :login))
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end
end
