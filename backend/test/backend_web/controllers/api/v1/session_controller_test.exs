defmodule BackendWeb.Api.V1.SessionControllerTest do
  use BackendWeb.ApiCase

  @valid_attrs %{
    email: "test@example.com",
    password: "password123",
    username: "testuser"
  }

  setup %{conn: conn} do
    {:ok, user} = Backend.Accounts.create_user(@valid_attrs)
    {:ok, conn: conn, user: user}
  end

  describe "create session" do
    test "returns token when credentials are valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/sessions", %{
        email: @valid_attrs.email,
        password: @valid_attrs.password
      })

      assert %{"success" => true} = json_response(conn, 200)
      assert %{"data" => %{"token" => token}} = json_response(conn, 200)
      assert is_binary(token)
    end

    test "returns error when credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/sessions", %{
        email: @valid_attrs.email,
        password: "wrongpassword"
      })

      assert %{"success" => false} = json_response(conn, 401)
      assert %{"error" => %{"message" => "Invalid credentials"}} = json_response(conn, 401)
    end
  end

  describe "delete session" do
    test "logs out user successfully", %{conn: conn, user: user} do
      conn = 
        conn
        |> authenticate_user(user)
        |> delete(~p"/api/v1/sessions")

      assert %{"success" => true} = json_response(conn, 200)
      assert %{"data" => %{"message" => "Successfully logged out"}} = json_response(conn, 200)
    end

    test "returns error when not authenticated", %{conn: conn} do
      conn = delete(conn, ~p"/api/v1/sessions")
      assert %{"success" => false} = json_response(conn, 401)
    end
  end
end
