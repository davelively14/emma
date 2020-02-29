defmodule Emma.Admin.Auth.ErrorHandlerTest do
  use EmmaWeb.ConnCase, async: true
  alias Emma.Admin.Auth.ErrorHandler

  describe "auth_error/3" do
    test "returns conn with 401 status regardless of type", %{conn: conn} do
      error_type = "error type"

      assert %Plug.Conn{status: 401, resp_body: ^error_type} =
               ErrorHandler.auth_error(conn, {error_type, "because"}, [])
    end
  end
end
