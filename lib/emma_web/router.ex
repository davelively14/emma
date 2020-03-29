defmodule EmmaWeb.Router do
  use EmmaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :auth do
    plug Emma.Admin.Auth.Pipeline
  end

  pipeline :ensure_auth do
    plug Emma.Admin.Auth.Pipeline
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmmaWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/session", SessionController, only: [:new, :create]
    resources "/user", UserController, only: [:new, :create]
  end

  scope "/", EmmaWeb do
    pipe_through [:browser, :ensure_auth]

    delete "/session", SessionController, :delete
  end

  scope "/app", EmmaWeb do
    pipe_through [:browser, :ensure_auth]

    get "/", AppController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmmaWeb do
  #   pipe_through :api
  # end
end
