defmodule Emma.Admin.Auth.ErrorHandlerTest do
  use EmmaWeb.ConnCase, async: true
  alias Emma.Admin.Auth.ErrorHandler

  describe "auth_error/3" do
    test "reroutes to root if unauthenticated error", %{conn: conn} do
      result_conn =
        conn
        |> bypass_through(EmmaWeb.Router, :browser)
        |> get("/")
        |> ErrorHandler.auth_error({:unauthenticated, :unauthenticated}, [])

      assert redirected_to(result_conn, 302) =~ "/"
    end

    test "returns conn with 401 status for any other type", %{conn: conn} do
      error_type = "error type"

      assert %Plug.Conn{status: 401, resp_body: ^error_type} =
               ErrorHandler.auth_error(conn, {error_type, "because"}, [])
    end
  end
end
