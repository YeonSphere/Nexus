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

# Add this to your existing config/config.exs
config :backend, Backend.Auth.Guardian,
  issuer: "backend",
  secret_key: "f4IBrIVDOO+JJilQxnlDh+dzufUlw86qamc8RcXzl7UmbQOZpxCmHA270u0u/bGa" # Use: mix guardian.gen.secret to generate a real one

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
