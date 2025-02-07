import Config

config :backend,
  ecto_repos: [Backend.Repo]

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: BackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Backend.PubSub,
  live_view: [signing_salt: "your_signing_salt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Update the Guardian configuration
config :backend, Backend.Authentication.Guardian,
  issuer: "backend",
  secret_key: "roonSLxE3xGFk1NATe2K5FCAavKxQk/IRl7VXTxNwQVyNlyvNGkzyyjXr4eRw+di" # Use: mix guardian.gen.secret to generate a real one

config :backend, Backend.Mailer,
  adapter: Swoosh.Adapters.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
