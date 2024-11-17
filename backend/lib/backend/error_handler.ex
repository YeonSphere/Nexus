defmodule Backend.ErrorHandler do
  @moduledoc """
  Comprehensive error handling for the Nexus backend.
  """

  require Logger
  alias Backend.ErrorView
  alias Phoenix.Controller

  @doc """
  Handles various types of errors and returns appropriate responses.
  """
  def handle_error(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> Controller.put_status(:unprocessable_entity)
    |> Controller.put_view(ErrorView)
    |> Controller.render("422.json", changeset: changeset)
  end

  def handle_error(conn, {:error, :not_found}) do
    conn
    |> Controller.put_status(:not_found)
    |> Controller.put_view(ErrorView)
    |> Controller.render("404.json")
  end

  def handle_error(conn, {:error, :unauthorized}) do
    conn
    |> Controller.put_status(:unauthorized)
    |> Controller.put_view(ErrorView)
    |> Controller.render("401.json")
  end

  def handle_error(conn, {:error, :forbidden}) do
    conn
    |> Controller.put_status(:forbidden)
    |> Controller.put_view(ErrorView)
    |> Controller.render("403.json")
  end

  def handle_error(conn, {:error, :bad_request, message}) do
    conn
    |> Controller.put_status(:bad_request)
    |> Controller.put_view(ErrorView)
    |> Controller.render("400.json", message: message)
  end

  def handle_error(conn, {:error, error}) when is_binary(error) do
    Logger.error("Unexpected error: #{error}")
    
    conn
    |> Controller.put_status(:internal_server_error)
    |> Controller.put_view(ErrorView)
    |> Controller.render("500.json", message: error)
  end

  def handle_error(conn, error) do
    Logger.error("Unhandled error: #{inspect(error)}")
    
    conn
    |> Controller.put_status(:internal_server_error)
    |> Controller.put_view(ErrorView)
    |> Controller.render("500.json")
  end

  @doc """
  Wraps a function with error handling.
  """
  defmacro with_error_handling(conn, do: block) do
    quote do
      try do
        case unquote(block) do
          {:ok, result} -> {:ok, result}
          {:error, _} = error -> handle_error(unquote(conn), error)
          result -> {:ok, result}
        end
      rescue
        e in Ecto.NoResultsError ->
          handle_error(unquote(conn), {:error, :not_found})
        
        e in Ecto.Query.CastError ->
          handle_error(unquote(conn), {:error, :bad_request, e.message})
        
        e ->
          Logger.error("Runtime error: #{inspect(e)}")
          Logger.error("Stacktrace: #{Exception.format(:error, e, __STACKTRACE__)}")
          handle_error(unquote(conn), {:error, "Internal server error"})
      end
    end
  end
end
