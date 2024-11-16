defmodule BackendWeb.StatusController do
  use BackendWeb, :controller

  @spec index(Plug.Conn.t(), map) :: Plug.Conn.t()
  def index(conn, _params) do
    json(conn, %{status: "Backend is running!"})
  end
end