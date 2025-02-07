defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: Backend.Auth.Guardian,
      error_handler: Backend.Auth.ErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  scope "/api/v1", BackendWeb.Api.V1 do
    pipe_through :api

    post "/users", UserController, :create
    get "/users/:id", UserController, :show
  end

  # Protected routes
  scope "/api/v1", BackendWeb.Api.V1 do
    pipe_through [:api, :auth]
    
    # Protected routes will go here
  end
end