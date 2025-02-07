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
        "/api/v1/users" => %{
          post: %{
            summary: "Create a new user",
            requestBody: %{
              required: true,
              content: %{
                "application/json" => %{
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
              "201" => %{
                description: "User created successfully",
                content: %{
                  "application/json" => %{
                    schema: %{
                      "$ref" => "#/components/schemas/UserResponse"
                    }
                  }
                }
              }
            }
          }
        },
        "/api/v1/sessions" => %{
          post: %{
            summary: "Create a new session",
            requestBody: %{
              required: true,
              content: %{
                "application/json" => %{
                  schema: %{
                    type: "object",
                    properties: %{
                      email: %{type: "string", format: "email"},
                      password: %{type: "string"}
                    },
                    required: ["email", "password"]
                  }
                }
              }
            },
            responses: %{
              "200" => %{
                description: "Session created successfully",
                content: %{
                  "application/json" => %{
                    schema: %{
                      "$ref" => "#/components/schemas/SessionResponse"
                    }
                  }
                }
              }
            }
          },
          delete: %{
            summary: "Delete current session",
            security: [%{bearerAuth: []}],
            responses: %{
              "200" => %{
                description: "Session deleted successfully"
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
                  user: %{
                    type: "object",
                    properties: %{
                      id: %{type: "integer"},
                      email: %{type: "string"},
                      username: %{type: "string"}
                    }
                  }
                }
              }
            }
          },
          SessionResponse: %{
            type: "object",
            properties: %{
              success: %{type: "boolean"},
              data: %{
                type: "object",
                properties: %{
                  user: %{
                    type: "object",
                    properties: %{
                      id: %{type: "integer"},
                      email: %{type: "string"},
                      username: %{type: "string"}
                    }
                  },
                  token: %{type: "string"}
                }
              }
            }
          }
        },
        securitySchemes: %{
          bearerAuth: %{
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        }
      }
    }
  end
end