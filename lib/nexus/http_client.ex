defmodule BackendWeb.HttpClient do
  @moduledoc """
  A module to handle HTTP requests
  """

  @doc """
  Makes a GET request to the given url and returns the response body
  """
  def get(url) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(url)
    body
  end

  @doc """
  Makes a POST request to the given url with the given body and returns the response body
  """
  def post(url, body) do
    %HTTPoison.Response{body: body} = HTTPoison.post!(url, body, [{"Content-Type", "application/json"}])
    body
  end

  @doc """
  Makes a PUT request to the given url with the given body and returns the response body
  """
  def put(url, body) do
    %HTTPoison.Response{body: body} = HTTPoison.put!(url, body, [{"Content-Type", "application/json"}])
    body
  end

  @doc """
  Makes a DELETE request to the given url and returns the response body
  """
  def delete(url) do
    %HTTPoison.Response{body: body} = HTTPoison.delete!(url)
    body
  end

  @doc """
  Makes a PATCH request to the given url with the given body and returns the response body
  """
  def patch(url, body) do
    %HTTPoison.Response{body: body} = HTTPoison.patch!(url, body, [{"Content-Type", "application/json"}])
    body
  end
end
