defmodule EmmaWeb.LiveView.LandingPage do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Live view is working: <%= @status %>
    """
  end

  def mount(_params, %{}, socket) do
    {:ok, assign(socket, :status, true)}
  end
end
