defmodule Backend.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Backend.Repo,
      BackendWeb.Telemetry,
      {Phoenix.PubSub, name: Backend.PubSub},
      BackendWeb.Endpoint
      # Remove or comment out DNSCluster if you're not using it
      # {DNSCluster, query: Application.get_env(:backend, :dns_cluster_query) || :ignore},
    ]

    opts = [strategy: :one_for_one, name: Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
