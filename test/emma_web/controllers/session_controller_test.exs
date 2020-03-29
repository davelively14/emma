defmodule EmmaWeb.SessionControllerTest do
  use EmmaWeb.ConnCase, async: true
  alias Test.Support.Admin.UserFactory
  alias Emma.Admin.Auth

  describe "GET /session/new" do
    test "renders login screen", %{conn: conn} do
      assert conn |> get("/session/new") |> html_response(200) =~ "Login"
    end
  end

  describe "POST /session" do
    test "redirects to /app with valid credentials", %{conn: conn} do
      password = "asdf1234"
      email = "bob@automotive.com"
      UserFactory.insert_user(email: email, password: password)

      payload = %{
        "user" => %{
          "email" => email,
          "password" => password
        }
      }

      assert conn |> post("/session", payload) |> redirected_to(302) =~ "/app"
    end

    test "authenticates with guardian", %{conn: conn} do
      password = "asdf1234"
      email = "bob@automotive.com"
      UserFactory.insert_user(email: email, password: password)

      payload = %{
        "user" => %{
          "email" => email,
          "password" => password
        }
      }

      assert conn |> post("/session", payload) |> Auth.Guardian.Plug.authenticated?()
    end

    test "renders new.html if invalid credentials", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "",
          "password" => ""
        }
      }

      assert conn |> post("/session", payload) |> html_response(200) =~
               "Invalid email or password"
    end

    test "renders new.html if malformed payload", %{conn: conn} do
      assert conn |> post("/session", %{}) |> html_response(200)
    end
  end

  describe "DELETE /session" do
    test "signs out user", %{conn: conn} do
      signed_in_conn = Emma.Admin.sign_in(conn, UserFactory.insert_user())

      refute signed_in_conn |> delete("/session") |> Auth.Guardian.Plug.authenticated?()
    end

    test "redirects user to root page", %{conn: conn} do
      signed_in_conn = Emma.Admin.sign_in(conn, UserFactory.insert_user())

      assert signed_in_conn |> delete("/session") |> redirected_to(302) =~ "/"
    end

    test "redirects user to root page even if not signed in", %{conn: conn} do
      assert conn |> delete("/session") |> redirected_to(302) =~ "/"
    end
  end
end
