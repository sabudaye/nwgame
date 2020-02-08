defmodule NwoneWeb.Router do
  use NwoneWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", NwoneWeb do
    pipe_through :browser

    get "/", GameController, :login
    post "/start", GameController, :start
    get "/game", GameController, :game
  end
end
