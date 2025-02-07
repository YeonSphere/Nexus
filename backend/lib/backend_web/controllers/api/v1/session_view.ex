defmodule BackendWeb.Api.V1.SessionView do
  use Jason.View

  def render("show.json", %{user: user, token: token}) do
    %{
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