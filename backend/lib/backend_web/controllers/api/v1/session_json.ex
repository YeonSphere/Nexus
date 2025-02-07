defmodule BackendWeb.Api.V1.SessionJSON do
  def show(%{user: user, token: token}) do
    %{
      success: true,
      data: %{
        user: %{
          id: user.id,
          email: user.email,
          username: user.username
        },
        token: token
      }
    }
  end
end