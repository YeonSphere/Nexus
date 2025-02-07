defmodule BackendWeb.ApiCase do
  @moduledoc """
  Test case template for API tests.
  Includes helpers for testing JSON responses and authentication.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use BackendWeb.ConnCase
      
      import BackendWeb.ApiCase
      alias BackendWeb.ApiJSON

      @endpoint BackendWeb.Endpoint

      # Helper for checking JSON response structure
      def has_json_structure?(json) do
        Map.has_key?(json, "success") and
          (Map.has_key?(json, "data") or Map.has_key?(json, "error"))
      end

      # Helper for creating test users
      def create_user(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(%{
            email: "test#{System.unique_integer()}@example.com",
            password: "password123",
            username: "testuser#{System.unique_integer()}"
          })
          |> Backend.Accounts.create_user()

        user
      end

      # Helper for authentication in tests
      def authenticate_user(conn, user) do
        {:ok, token, _claims} = Backend.Auth.Guardian.encode_and_sign(user)
        put_req_header(conn, "authorization", "Bearer #{token}")
      end
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Backend.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end