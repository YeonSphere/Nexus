defmodule BackendWeb.Api.V1.UserControllerTest do
  use BackendWeb.ApiCase

  @valid_attrs %{
    email: "test@example.com",
    password: "password123",
    username: "testuser"
  }
  @invalid_attrs %{email: "invalid", password: "short", username: nil}

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: @valid_attrs)
      assert %{"success" => true} = json_response(conn, 201)
      
      assert %{
        "data" => %{
          "user" => %{
            "email" => "test@example.com",
            "username" => "testuser"
          }
        }
      } = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: @invalid_attrs)
      assert %{"success" => false} = json_response(conn, 422)
      assert %{"error" => %{"details" => _details}} = json_response(conn, 422)
    end
  end

  describe "show user" do
    setup [:create_user]

    test "renders user when user exists", %{conn: conn, user: user} do
      conn = 
        conn
        |> authenticate_user(user)
        |> get(~p"/api/v1/users/#{user.id}")

      assert %{"success" => true} = json_response(conn, 200)
      assert %{
        "data" => %{
          "user" => %{
            "id" => id,
            "email" => email,
            "username" => username
          }
        }
      } = json_response(conn, 200)
      
      assert to_string(user.id) == to_string(id)
      assert user.email == email
      assert user.username == username
    end

    test "renders error when user doesn't exist", %{conn: conn, user: user} do
      conn = 
        conn
        |> authenticate_user(user)
        |> get(~p"/api/v1/users/999999")

      assert %{"success" => false} = json_response(conn, 404)
    end

    test "renders error when not authenticated", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/v1/users/#{user.id}")
      assert %{"success" => false} = json_response(conn, 401)
    end
  end
end
