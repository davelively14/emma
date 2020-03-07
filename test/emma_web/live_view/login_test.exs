defmodule EmmaWeb.LiveView.LoginTest do
  use EmmaWeb.ConnCase, async: true
  import Phoenix.LiveViewTest, only: [live: 1, render_submit: 3, assert_redirect: 3]
  alias Test.Support.Admin.UserFactory

  describe "mount" do
    test "can mount in disconnected status", %{conn: conn} do
      conn = get(conn, "/login")

      assert html_response(conn, 200) =~ "Login"
    end

    test "mounts in connected status", %{conn: conn} do
      conn = get(conn, "/login")

      assert {:ok, %Phoenix.LiveViewTest.View{}, html} = live(conn)
      assert html =~ "Login"
    end
  end

  describe "login event" do
    test "redirects to app on success", %{conn: conn} do
      email = "valid@bob.com"
      password = "asdf1234"
      user_params = %{"email" => email, "password" => password}
      UserFactory.insert_user(email: email, password: password)

      {:ok, view, _html} =
        conn
        |> get("/login")
        |> live()

      render_submit(view, :login, %{"user" => user_params})

      assert_redirect(view, "/app", %{"info" => "Logged in"})
    end

    test "displays error if bad password", %{conn: conn} do
      email = "valid@bob.com"
      password = "asdf1234"
      user_params = %{"email" => email, "password" => "#{password}+wrong"}
      UserFactory.insert_user(email: email, password: password)

      {:ok, view, _html} =
        conn
        |> get("/login")
        |> live()

      assert render_submit(view, :login, %{"user" => user_params}) =~
               "Invalid email or password. Please try again."
    end

    test "displays error if bad username", %{conn: conn} do
      email = "valid@bob.com"
      password = "asdf1234"
      user_params = %{"email" => "#{email}mm", "password" => password}
      UserFactory.insert_user(email: email, password: password)

      {:ok, view, _html} =
        conn
        |> get("/login")
        |> live()

      assert render_submit(view, :login, %{"user" => user_params}) =~
               "Invalid email or password. Please try again."
    end
  end
end
