defmodule BackendWeb.Api.V1.UserControllerTest do
  use BackendWeb.ConnCase

  @valid_attrs %{
    email: "test@example.com",
    password: "password123",
    username: "testuser"
  }

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: @valid_attrs)
      assert %{"data" => %{"id" => id}} = json_response(conn, 201)

      conn = get(conn, ~p"/api/v1/users/#{id}")
      assert %{
        "data" => %{
          "id" => ^id,
          "email" => "test@example.com",
          "username" => "testuser"
        }
      } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/users", user: %{email: "invalid"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/v1/users/#{user.id}", user: %{email: "updated@example.com"})
      assert %{"data" => %{"id" => ^user.id}} = json_response(conn, 200)

      conn = get(conn, ~p"/api/v1/users/#{user.id}")
      assert %{
        "data" => %{
          "id" => ^user.id,
          "email" => "updated@example.com",
          "username" => user.username
        }
      } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, ~p"/api/v1/users/#{user.id}", user: %{email: "invalid"})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = insert(:user)
    {:ok, user: user}
  end
end