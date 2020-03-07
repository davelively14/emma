defmodule EmmaWeb.Router do
  use EmmaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmmaWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/app", AppController, :index
    get "/login", AdminController, :login
    get "/create_user", AdminController, :create_user
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmmaWeb do
  #   pipe_through :api
  # end
end
