defmodule EmmaWeb.AdminControllerTest do
  use EmmaWeb.ConnCase, async: true

  describe "GET /login" do
    test "returns login page", %{conn: conn} do
      conn = get(conn, "/login")

      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "GET /create_user" do
    test "returns create user page", %{conn: conn} do
      conn = get(conn, "/create_user")

      assert html_response(conn, 200) =~ "Create User"
    end
  end
end
