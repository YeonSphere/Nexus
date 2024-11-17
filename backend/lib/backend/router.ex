defmodule Backend.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Backend do
    pipe_through :api

    get "/health", HealthController, :check
    post "/tabs/create", TabController, :create
    post "/tabs/update", TabController, :update
    delete "/tabs/:id", TabController, :delete
    get "/tabs", TabController, :list
  end
end
