import Config

# Configure your database connection
config :backend, Backend.Repo,
  username: System.get_env("DATABASE_USERNAME") || raise("DATABASE_USERNAME not set in prod.exs"),
  password: System.get_env("DATABASE_PASSWORD") || raise("DATABASE_PASSWORD not set in prod.exs"),
  database: System.get_env("DATABASE_NAME") || raise("DATABASE_NAME not set in prod.exs"),
  hostname: System.get_env("DATABASE_HOST") || raise("DATABASE_HOST not set in prod.exs"),  # Get from env or set a default
  pool_size: System.get_env("DATABASE_POOL_SIZE") || 10 # Get from env or set a default

# Configure your Phoenix endpoint
config :backend, BackendWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")], # Use env for port, 0.0.0.0 for all interfaces
  check_origin: System.get_env("CHECK_ORIGIN") == "true", # Only true if explicitly set to "true"
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE not set in prod.exs"),
  server: true, # Important: Enable the server for production
  root: ".", # Important: Set the root to the current directory
  static_paths: ["_build/prod/static"] # Important: Set the static paths for production

# Configure logging (adjust as needed for your production environment)
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configure Swoosh (adjust for your production mailer)
config :swoosh,
  adapter: Swoosh.Adapters.SendGrid, # Or your preferred adapter
  api_key: System.get_env("SENDGRID_API_KEY") || raise("SENDGRID_API_KEY not set in prod.exs") # Or other configuration

# Do NOT enable dev routes in production!
config :backend, dev_routes: false # Absolutely crucial!

# Configure static file serving for production
config :phoenix, :serve_static_from_build, true

# Configure the url host to be used for url generation
config :backend, :url,
  host: System.get_env("APP_URL") || raise("APP_URL not set in prod.exs")