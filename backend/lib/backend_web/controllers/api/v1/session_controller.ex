defmodule BackendWeb.Api.V1.SessionController do
  use BackendWeb, :controller, otp_app: :backend

  alias Backend.Authentication.Authenticator
  alias Backend.Authentication.Guardian
  alias BackendWeb.ApiJSON

  def create(conn, %{"email" => email, "password" => password}) do
    case Authenticator.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Authenticator.generate_token(user)

        conn
        |> put_status(:ok)
        |> json(ApiJSON.success(%{
          user: %{
            id: user.id,
            email: user.email,
            username: user.username
          },
          token: token
        }))

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(ApiJSON.error("Invalid credentials", nil, :unauthorized))
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> json(ApiJSON.success(%{message: "Successfully logged out"}))
  end
end