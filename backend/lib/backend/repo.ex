defmodule Backend.Repo do
  use Ecto.Repo, otp_app: :backend, adapter: Ecto.Adapters.Postgres  # <--- Add adapter: Ecto.Adapters.Postgres

  # If using a database URL, uncomment and replace the line below
  # config :backend, Backend.Repo, url: System.get_env("DATABASE_URL")

end