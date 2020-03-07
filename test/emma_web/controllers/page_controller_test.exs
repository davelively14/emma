defmodule EmmaWeb.PageControllerTest do
  use EmmaWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Emma"
  end
end
