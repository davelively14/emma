defmodule EmmaWeb.LiveView.CreateUser do
  use Phoenix.LiveView
  alias Emma.Admin
  alias EmmaWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(EmmaWeb.AdminView, "create_user.html", assigns)
  end

  def mount(_params, %{}, socket) do
    new_socket =
      socket
      |> assign(:invalid_credentials, false)
      |> assign(:changeset, Admin.user_changeset())

    {:ok, new_socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      params
      |> Admin.user_changeset()
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create", %{"user" => params}, socket) do
    case Admin.create_user(params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User created")
         |> redirect(to: Routes.app_path(EmmaWeb.Endpoint, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
