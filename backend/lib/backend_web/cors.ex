defmodule BackendWeb.CORS do
  @moduledoc """
  CORS configuration for the API.
  """

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
    |> Plug.Conn.put_resp_header("access-control-allow-methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
    |> Plug.Conn.put_resp_header("access-control-allow-headers", "Authorization, Content-Type, Accept, Origin, User-Agent")
    |> Plug.Conn.put_resp_header("access-control-expose-headers", "Authorization")
  end
end