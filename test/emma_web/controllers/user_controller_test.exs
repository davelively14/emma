defmodule EmmaWeb.UserControllerTest do
  use EmmaWeb.ConnCase, async: true
  alias Test.Support.Admin.UserFactory
  alias Emma.Admin.Auth

  describe "GET /user/new" do
    test "renders user creation page", %{conn: conn} do
      assert conn |> get("/user/new") |> html_response(200) =~ "Create User"
    end
  end

  describe "POST /user" do
    test "creates a user with valid details", %{conn: conn} do
      email = "test1234@gtest.com"

      payload = %{
        "user" => %{
          "email" => email,
          "password" => "asdf1234"
        }
      }

      post(conn, "/user", payload)

      assert Emma.Admin.User |> Emma.Repo.get_by(email: email)
    end

    test "redirects to /app upon successful creation", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "querty@email.com",
          "password" => "asdf1234"
        }
      }

      assert conn |> post("/user", payload) |> redirected_to(302) =~ "/app"
    end

    test "authenticates with new user via guardian", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "fj8234kas@email.com",
          "password" => "asdf1234"
        }
      }

      assert conn |> post("/user", payload) |> Auth.Guardian.Plug.authenticated?()
    end

    test "renders already taken error if email already exists in db", %{conn: conn} do
      %{email: email} = UserFactory.insert_user()

      payload = %{
        "user" => %{
          "email" => email,
          "password" => "asdf1234"
        }
      }

      assert conn |> post("/user", payload) |> html_response(200) =~ "has already been taken"
    end

    test "renders can't be blank error if password empty", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "d@valid.com",
          "password" => ""
        }
      }

      assert conn |> post("/user", payload) |> html_response(200) =~ "can&#39;t be blank"
    end

    test "renders can't be blank error if email empty", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "",
          "password" => "asdf1234"
        }
      }

      assert conn |> post("/user", payload) |> html_response(200) =~ "can&#39;t be blank"
    end

    test "renders invalid format error if email incorrectly formatted", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "not a valid email",
          "password" => "asdf1234"
        }
      }

      assert conn |> post("/user", payload) |> html_response(200) =~ "not a valid email"
    end

    test "renders too short error if password less than 8 characters", %{conn: conn} do
      payload = %{
        "user" => %{
          "email" => "valid@gmail.com",
          "password" => "asdf123"
        }
      }

      assert conn |> post("/user", payload) |> html_response(200) =~
               "should be at least 8 character(s)"
    end

    test "renders new.html with if malformed params", %{conn: conn} do
      assert conn |> post("/user", %{}) |> html_response(200) =~ "Create User"
    end
  end
end
