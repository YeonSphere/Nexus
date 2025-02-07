defmodule BackendWeb.OpenAPI do
  @moduledoc """
  OpenAPI specification for the API.
  This will help generate Rust client code.
  """

  def spec do
    %{
      openapi: "3.0.0",
      info: %{
        title: "Backend API",
        version: "1.0.0"
      },
      paths: %{
        "/api/v1/users": %{
          post: %{
            summary: "Create a new user",
            requestBody: %{
              required: true,
              content: %{
                "application/json": %{
                  schema: %{
                    type: "object",
                    properties: %{
                      email: %{type: "string", format: "email"},
                      password: %{type: "string", minLength: 8},
                      username: %{type: "string", minLength: 3}
                    },
                    required: ["email", "password", "username"]
                  }
                }
              }
            },
            responses: %{
              201: %{
                description: "User created successfully",
                content: %{
                  "application/json": %{
                    schema: %{ref: "#/components/schemas/UserResponse"}
                  }
                }
              }
            }
          }
        }
      },
      components: %{
        schemas: %{
          UserResponse: %{
            type: "object",
            properties: %{
              success: %{type: "boolean"},
              data: %{
                type: "object",
                properties: %{
                  id: %{type: "integer"},
                  email: %{type: "string"},
                  username: %{type: "string"}
                }
              }
            }
          }defmodule BackendWeb.Router do
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
    post "/sessions", SessionController, :create
  end

  # Protected routes
  scope "/api/v1", BackendWeb.Api.V1 do
    pipe_through [:api, :auth]
    
    get "/users/:id", UserController, :show
    delete "/sessions", SessionController, :delete
  end
end
        }
      }
    }
  end
end