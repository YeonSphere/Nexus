defmodule BackendWeb.ApiJSON do
  @moduledoc """
  Standardized JSON response structure for API endpoints.
  Designed to be easily deserializable by Rust's serde.
  """

  def success(data, meta \\ %{}) do
    %{
      success: true,
      data: data,
      meta: meta,
      error: nil
    }
  end

  def error(message, details \\ nil, status \\ :bad_request) do
    %{
      success: false,
      data: nil,
      error: %{
        message: message,
        details: details,
        status: status_code(status)
      }
    }
  end

  # Map common atoms to HTTP status codes
  defp status_code(:bad_request), do: 400
  defp status_code(:unauthorized), do: 401
  defp status_code(:forbidden), do: 403
  defp status_code(:not_found), do: 404
  defp status_code(:conflict), do: 409
  defp status_code(:unprocessable_entity), do: 422
  defp status_code(:internal_server_error), do: 500
  defp status_code(code) when is_integer(code), do: code
end