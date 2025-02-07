defmodule Backend.Authentication do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Authentication.Guardian
  alias Backend.Schemas.User

  def authenticate_user(email, password) do
    query = from u in User, where: u.email == ^email

    case Repo.one(query) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def generate_token(user) do
    Guardian.encode_and_sign(user)
  end

  def verify_token(token) do
    Guardian.resource_from_token(token)
  end

  def get_current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end