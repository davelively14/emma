defmodule Emma.Admin.Auth.ErrorHandler do
  use EmmaWeb, :controller
  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]
  alias EmmaWeb.Router.Helpers, as: Routes

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    conn
    |> put_flash(:info, "Must be logged in to access that page.")
    |> redirect(to: Routes.page_path(EmmaWeb.Endpoint, :index))
  end

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, to_string(type))
  end
end
