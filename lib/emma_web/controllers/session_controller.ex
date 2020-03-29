defmodule EmmaWeb.SessionController do
  use EmmaWeb, :controller
  alias Emma.Admin
  alias EmmaWeb.Router.Helpers, as: Routes

  def new(conn, _params) do
    render(conn, "new.html", changeset: Admin.user_changeset(), invalid_credentials: false)
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Admin.authenticate(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back, #{user.email}")
        |> Admin.sign_in(user)
        |> redirect(to: Routes.app_path(EmmaWeb.Endpoint, :index))

      {:error, :invalid_credentials} ->
        render(conn, "new.html",
          changeset: Admin.user_changeset(%{email: email}),
          invalid_credentials: true
        )
    end
  end

  def create(conn, _malformed_payload) do
    render(conn, "new.html", changeset: Admin.user_changeset(), invalid_credentials: false)
  end

  def delete(conn, _params) do
    conn
    |> Admin.sign_out()
    |> redirect(to: Routes.page_path(EmmaWeb.Endpoint, :index))
  end
end
