defmodule EmmaWeb.LiveView.CreateUserTest do
  use EmmaWeb.ConnCase, async: true

  import Phoenix.LiveViewTest,
    only: [live: 1, render_change: 3, render_submit: 3, assert_redirect: 3]

  describe "mount" do
    test "can mount in disconnected status", %{conn: conn} do
      conn = get(conn, "/create_user")

      assert html_response(conn, 200) =~ "Create User"
    end

    test "mounts in connected status", %{conn: conn} do
      conn = get(conn, "/create_user")

      assert {:ok, %Phoenix.LiveViewTest.View{}, html} = live(conn)
      assert html =~ "Create User"
    end
  end

  describe "validate event" do
    test "displays error if email format invalid", %{conn: conn} do
      user_params = %{email: "invalid", password: "asdf1234"}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      assert render_change(view, :validate, %{"user" => user_params}) =~ "has invalid format"
    end

    test "displays error if password format invalid", %{conn: conn} do
      user_params = %{email: "valid@email.com", password: "toshort"}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      assert render_change(view, :validate, %{"user" => user_params}) =~
               "should be at least 8 character(s)"
    end

    test "displays error if password blank", %{conn: conn} do
      user_params = %{email: "valid@email.com", password: ""}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      assert render_change(view, :validate, %{"user" => user_params}) =~ "can&apos;t be blank"
    end

    test "displays error if username blank", %{conn: conn} do
      user_params = %{email: "", password: "asdf1234"}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      assert render_change(view, :validate, %{"user" => user_params}) =~ "can&apos;t be blank"
    end
  end

  describe "create event" do
    test "creates a user on successful submit", %{conn: conn} do
      email = "valid@email.com"
      user_params = %{email: email, password: "asdf1234"}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      render_submit(view, :create, %{"user" => user_params})

      assert %{email: ^email} = Emma.Admin.User |> Emma.Repo.get_by(email: email)
    end

    test "success redirects to /app", %{conn: conn} do
      user_params = %{email: "valid@em.com", password: "asdf1234"}

      {:ok, view, _html} =
        conn
        |> get("/create_user")
        |> live()

      render_submit(view, :create, %{"user" => user_params})

      assert_redirect(view, "/app", %{"info" => "User created"})
    end
  end
end
