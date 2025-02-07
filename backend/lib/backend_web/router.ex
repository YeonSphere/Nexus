defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug BackendWeb.CORS
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: Backend.Authentication.Guardian,
      error_handler: Backend.Authentication.ErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  scope "/api/v1", BackendWeb.Api.V1 do
    pipe_through :api

    # Public endpoints
    post "/users", UserController, :create
    post "/sessions", SessionController, :create

    # Auth required endpoints
    pipe_through :auth
    get "/users/me", UserController, :show_current
    get "/users/:id", UserController, :show
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete
    delete "/sessions", SessionController, :delete
  end
end