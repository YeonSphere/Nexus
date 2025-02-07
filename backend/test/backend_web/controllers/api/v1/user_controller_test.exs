defmodule BackendWeb.Api.V1.UserControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Accounts
  alias Backend.Authentication.Guardian

  @valid_attrs %{
    email: "test@example.com",
    password: "password123",
    username: "testuser"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: @valid_attrs)
      assert %{"success" => true} = json_response(conn, 201)
      assert %{"data" => %{"user" => %{"email" => "test@example.com"}}} = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: %{email: "invalid"})
      assert %{"success" => false} = json_response(conn, 422)
    end
  end

  describe "show user" do
    setup [:create_user]

    test "renders user when authenticated", %{conn: conn, user: user} do
      {:ok, token, _} = Guardian.encode_and_sign(user)
      conn = conn 
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/v1/users/#{user.id}")

      assert %{"success" => true} = json_response(conn, 200)
      assert %{"data" => %{"user" => %{"id" => id}}} = json_response(conn, 200)
      assert to_string(user.id) == to_string(id)
    end

    test "renders error when not authenticated", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/v1/users/#{user.id}")
      assert %{"success" => false} = json_response(conn, 401)
    end
  end

  describe "show current user" do
    setup [:create_user]

    test "renders current user when authenticated", %{conn: conn, user: user} do
      {:ok, token, _} = Guardian.encode_and_sign(user)
      conn = conn 
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(~p"/api/v1/users/me")

      assert %{"success" => true} = json_response(conn, 200)
      assert %{"data" => %{"user" => %{"id" => id}}} = json_response(conn, 200)
      assert to_string(user.id) == to_string(id)
    end
  end

  defp create_user(_) do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    %{user: user}
  end
end