defmodule EmmaWeb.LiveView.Login do
  use Phoenix.LiveView
  alias Emma.Admin
  alias EmmaWeb.Router.Helpers, as: Routes

  def render(assigns) do
    Phoenix.View.render(EmmaWeb.AdminView, "login.html", assigns)
  end

  def mount(_params, %{}, socket) do
    new_socket =
      socket
      |> assign(:invalid_credentials, false)
      |> assign(:changeset, Admin.user_changeset())

    {:ok, new_socket}
  end

  def handle_event("login", %{"user" => %{"email" => email, "password" => password}}, socket) do
    case Admin.authenticate(email, password) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Logged in")
         |> redirect(to: Routes.app_path(EmmaWeb.Endpoint, :index))}

      {:error, :invalid_credentials} ->
        {:noreply, socket |> assign(:invalid_credentials, true)}
    end
  end
end
