defmodule Backend.AuthHelpers do
  @moduledoc """
  Helper functions for authentication in tests.
  """

  import Plug.Conn
  alias Backend.Authentication.Guardian

  @doc """
  Logs a user in to the given connection.
  """
  def login_user(conn, user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    put_req_header(conn, "authorization", "Bearer #{token}")
  end

  @doc """
  Generates a JWT for the given user.
  """
  def generate_token(user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    token
  end
end
