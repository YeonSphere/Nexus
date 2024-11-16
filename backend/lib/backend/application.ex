defmodule Backend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Initialize ETS tables
    :ets.new(:bookmarks, [:set, :public, :named_table])
    :ets.new(:rate_limiter, [:set, :public, :named_table])

    children = [
      # Start the Telemetry supervisor
      BackendWeb.Telemetry,
      # Start DNS clustering
      {DNSCluster, query: Application.get_env(:dns_cluster, :query) || "localhost"},
      # Start PubSub system
      {Phoenix.PubSub, name: Backend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Backend.Finch},
      # Start to serve requests
      BackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Backend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
