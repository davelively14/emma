defmodule EmmaWeb.UserController do
  use EmmaWeb, :controller
  alias Emma.Admin
  alias EmmaWeb.Router.Helpers, as: Routes

  def new(conn, _params) do
    render(conn, "new.html", changeset: Admin.user_changeset())
  end

  def create(conn, %{"user" => params}) do
    case Admin.create_user(params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Created user with email #{user.email}")
        |> Admin.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: Routes.app_path(EmmaWeb.Endpoint, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, _malformed_params) do
    render(conn, "new.html", changeset: Admin.user_changeset())
  end
end
