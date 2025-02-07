defmodule BackendWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Every test runs inside a transaction which is reset
  at the beginning of the test unless the test case
  is marked as `async: true`, in which case the tests
  run in parallel with their own connection to the
  database. Every test runs inside a transaction
  which is reset at the beginning of the test unless
  the test is marked as `async: true`, in which case
  the test runs in parallel and is not reset
  automatically.

  You may define functions on this module to be used
  as helpers in your tests. Since the test client is
  just a regular ExUnit test, you can also use any
  ExUnit-maintained helpers which you have imported
  in `test_helper.exs`.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import BackendWeb.ConnCase

      # Import path helpers
      import BackendWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BackendWeb.Endpoint

      # Add ~p sigil for path generation
      import Phoenix.VerifiedRoutes
      alias BackendWeb.Router.Helpers, as: Routes
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Backend.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
