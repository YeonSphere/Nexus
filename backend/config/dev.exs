import Config

# Configure your database connection
config :backend, Backend.Repo,
  username: System.get_env("DATABASE_USERNAME") || "your_dev_db_user", # Fallback for development
  password: System.get_env("DATABASE_PASSWORD") || "your_dev_db_password", # Fallback for development
  database: System.get_env("DATABASE_NAME") || "your_dev_db_name", # Fallback for development
  hostname: System.get_env("DATABASE_HOST") || "localhost", # Fallback for development
  pool_size: System.get_env("DATABASE_POOL_SIZE") || 10

# Configure your Phoenix endpoint
config :backend, BackendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000], # Usually localhost for dev
  check_origin: false, # Only false in development!  Set to true in production
  code_reloader: true, # Enable code reloading for faster development
  debug_errors: true, # Show detailed error pages in development
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE not set in dev.exs"), # Get from env or generate
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:backend, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:backend, ~w(--watch)]}
  ]

# Enable dev routes for dashboard and mailbox (OK in development)
config :backend, dev_routes: true

# Configure logging (adjust as needed)
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace depth in development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable Swoosh API client in development (usually OK)
config :swoosh, :api_client, false

# Configure mailer for development (usually :test adapter)
config :backend, Backend.Mailer,
  adapter: Swoosh.Adapters.Test # Or :smtp if you have a local mail server setup