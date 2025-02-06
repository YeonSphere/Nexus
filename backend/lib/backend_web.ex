defmodule BackendWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers and routers for API usage.
  """

  def controller do
    quote do
      use Phoenix.Controller,
        namespace: BackendWeb,
        formats: [:json]  # Only JSON for API

      import Plug.Conn
      import BackendWeb.Gettext
      import BackendWeb.Router.Helpers, as: Routes  # Correctly import routes
    end
  end

  def router do
    quote do
      use Phoenix.Router,
        helpers: false  # Disable route helpers for API

      import Plug.Static,
        at: "/", from: :backend, only: ~w(css fonts images js favicon.ico robots.txt)

      # Import common plugins
      import Phoenix.Controller  # This is needed for controller functions
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  defmacro __using__(which) do
    quote do
      unquote(case which do
        :controller -> controller()
        :router -> router()
        :channel -> channel()
        _ -> raise "Unsupported context: #{inspect(which)}"
      end)
    end
  end

  def static_paths do
    ["priv/static"]  # Only serve static assets
  end
end