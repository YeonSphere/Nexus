defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug BackendWeb.CORS
    plug Plug.RequestId
  end

  pipeline :auth do
    plug Guardian.Plug.Pipeline,
      module: Backend.Authentication.Guardian,
      error_handler: Backend.Authentication.ErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  # Public API endpoints
  scope "/api/v1", BackendWeb.Api.V1, as: :api_v1 do
    pipe_through :api

    post "/users", UserController, :create
    post "/sessions", SessionController, :create
    options "/users", UserController, :options
    options "/sessions", SessionController, :options
  end

  # Protected API endpoints
  scope "/api/v1", BackendWeb.Api.V1, as: :api_v1 do
    pipe_through [:api, :auth]
    
    get "/users/:id", UserController, :show
    get "/users/me", UserController, :current
    delete "/sessions", SessionController, :delete
    
    options "/users/:id", UserController, :options
    options "/users/me", UserController, :options
    options "/sessions", SessionController, :options
  end
end