defmodule Backend.AuthFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Auth` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{

      })
      |> Backend.Auth.create_token()

    token
  end
end
