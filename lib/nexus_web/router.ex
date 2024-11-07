defmodule NexusWeb.Router do
  use NexusWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api", NexusWeb do
    pipe_through :api
    
    resources "/bookmarks", BookmarkController, except: [:new, :edit]
    resources "/tabs", TabController, except: [:new, :edit]
    resources "/downloads", DownloadController, except: [:new, :edit]
    resources "/settings", SettingController, only: [:index, :update]
    resources "/extensions", ExtensionController, except: [:new, :edit]
  end

  socket "/socket", NexusWeb.UserSocket,
    websocket: true,
    longpoll: false
end
