defmodule NwoneWeb.GameControllerTest do
  use NwoneWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200)
  end

  test "GET /game?name=test", %{conn: conn} do
    conn = get(conn, "/game?name=test")
    assert html_response(conn, 200)
  end
end
