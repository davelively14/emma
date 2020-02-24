defmodule Emma.Admin.Auth.ErrorHandler do
  import Plug.Conn, only: [put_resp_content_type: 2, send_resp: 3]

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, to_string(type))
  end
end
