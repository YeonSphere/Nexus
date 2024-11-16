defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost:3000", "https://nexus.yeonsphere.com"]
    plug BackendWeb.RateLimiter
  end

  scope "/", BackendWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", BackendWeb do
    pipe_through :api

    # Status endpoint
    get "/status", StatusController, :index

    # Bookmark endpoints
    resources "/bookmarks", BookmarksController, only: [:index, :create, :show, :update, :delete]
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:backend, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BackendWeb.Telemetry
    end
  end
end