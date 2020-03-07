defmodule EmmaWeb.AppControllerTest do
  use EmmaWeb.ConnCase, async: true

  test "GET /app", %{conn: conn} do
    conn = get(conn, "/app")
    assert html_response(conn, 200) =~ "App Goes Here"
  end
end
