defmodule BackendWeb.Api.V1.UserJSON do
  def show(%{user: user}) do
    %{
      success: true,
      data: %{
        user: %{
          id: user.id,
          email: user.email,
          username: user.username
        }
      }
    }
  end

  def user(%{user: user}) do
    %{
      id: user.id,
      email: user.email,
      username: user.username
    }
  end
end