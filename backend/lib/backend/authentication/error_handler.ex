defmodule Backend.Authentication.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      success: false,
      error: %{
        message: to_string(type),
        status: 401
      }
    })
  end
end
