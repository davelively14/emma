defmodule EmmaWeb.AppController do
  use EmmaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_user: Guardian.Plug.current_resource(conn))
  end
end
