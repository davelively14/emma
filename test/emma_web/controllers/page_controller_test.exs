defmodule EmmaWeb.PageControllerTest do
  use EmmaWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Live view is working: true"
  end
end
