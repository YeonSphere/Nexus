defmodule BackendWeb.PageController do
  use Phoenix.Controller  # Use BackendWeb.Controller directly

  def index(conn, _params) do
    json(conn, %{message: "Welcome to the API!"})  # Return a welcome message as JSON
  end
end