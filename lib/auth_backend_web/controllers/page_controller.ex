defmodule AuthBackendWeb.PageController do
  use AuthBackendWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
