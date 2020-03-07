defmodule EmmaWeb.AdminController do
  use EmmaWeb, :controller

  def login(conn, _params) do
    live_render(conn, EmmaWeb.LiveView.Login)
  end

  def create_user(conn, _params) do
    live_render(conn, EmmaWeb.LiveView.CreateUser)
  end
end
