defmodule Backend.ErrorView do
  use BackendWeb, :view

  def render("400.json", %{message: message}) do
    %{
      error: %{
        status: 400,
        message: message || "Bad Request",
        type: "bad_request"
      }
    }
  end

  def render("401.json", _assigns) do
    %{
      error: %{
        status: 401,
        message: "Unauthorized",
        type: "unauthorized"
      }
    }
  end

  def render("403.json", _assigns) do
    %{
      error: %{
        status: 403,
        message: "Forbidden",
        type: "forbidden"
      }
    }
  end

  def render("404.json", _assigns) do
    %{
      error: %{
        status: 404,
        message: "Resource not found",
        type: "not_found"
      }
    }
  end

  def render("422.json", %{changeset: changeset}) do
    %{
      error: %{
        status: 422,
        message: "Validation failed",
        type: "validation_error",
        details: translate_errors(changeset)
      }
    }
  end

  def render("500.json", %{message: message}) do
    %{
      error: %{
        status: 500,
        message: message || "Internal server error",
        type: "server_error"
      }
    }
  end

  def render("500.json", _assigns) do
    %{
      error: %{
        status: 500,
        message: "Internal server error",
        type: "server_error"
      }
    }
  end

  # Translate changeset errors to a map of field -> error messages
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
