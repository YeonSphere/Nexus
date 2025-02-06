defmodule BackendWeb.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]  # Only accept JSON requests
  end

  scope "/", BackendWeb do
    get "/", PageController, :index  # Route for the root path
  end

  scope "/api", BackendWeb do
    pipe_through :api

    resources "/products", ProductController  # API routes for products
  end

  # Uncomment this section if you want to enable the LiveDashboard for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :api  # Use API pipeline for LiveDashboard
      live_dashboard "/dashboard", metrics: BackendWeb.Telemetry
    end
  end
end