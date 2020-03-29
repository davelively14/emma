defmodule EmmaWeb.AppControllerTest do
  use EmmaWeb.ConnCase, async: true
  alias Test.Support.Admin.UserFactory
  alias Emma.Admin

  describe "GET /app - logged in" do
    setup :log_in

    test "loads index template when logged in", %{auth_conn: conn} do
      assert conn |> get("/app") |> html_response(200) =~ "App Goes Here"
    end
  end

  describe "GET /app - not logged in" do
    test "redirects to root when not logged in", %{conn: conn} do
      conn = get(conn, "/app")
      assert redirected_to(conn, 302) =~ "/"
    end

    test "flashes redirection notification", %{conn: conn} do
      initial_conn = get(conn, "/app")
      redir_path = redirected_to(initial_conn, 302)

      final_conn =
        initial_conn
        |> recycle()
        |> get(redir_path)

      assert get_flash(final_conn, :info) =~ "Must be logged in to access that page."
    end
  end

  # Setup functions

  defp log_in(%{conn: conn}) do
    user = UserFactory.insert_user()
    token = Admin.get_token_for_user(user)
    auth_conn = put_req_header(conn, "authorization", "bearer: " <> token)

    {:ok, %{user: user, token: token, auth_conn: auth_conn}}
  end
end
