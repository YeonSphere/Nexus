defmodule BackendWeb.PageController do
  use BackendWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
