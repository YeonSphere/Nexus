defmodule Nexus.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NexusWeb.Endpoint,
      {Phoenix.PubSub, name: Nexus.PubSub},
      Nexus.BrowserEngine,
      Nexus.TabManager,
      Nexus.BookmarkManager,
      Nexus.DownloadManager,
      Nexus.SettingsManager,
      Nexus.ExtensionManager
    ]

    opts = [strategy: :one_for_one, name: Nexus.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NexusWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
