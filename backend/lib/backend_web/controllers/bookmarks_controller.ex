defmodule BackendWeb.BookmarksController do
  use BackendWeb, :controller

  @bookmark_table :bookmarks
  @max_bookmarks 1000
  @url_regex ~r/^https?:\/\/.+/

  def index(conn, _params) do
    try do
      bookmarks = :ets.tab2list(@bookmark_table)
      conn
      |> put_status(:ok)
      |> json(%{bookmarks: Enum.map(bookmarks, fn {_, url} -> url end)})
    catch
      :error, :badarg ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Bookmark storage unavailable"})
    end
  end

  def create(conn, %{"url" => url}) do
    with {:ok, _} <- validate_url(url),
         {:ok, _} <- check_bookmark_limit(),
         {:ok, _} <- insert_bookmark(url) do
      conn
      |> put_status(:created)
      |> json(%{message: "Bookmark added", url: url})
    else
      {:error, :invalid_url} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid URL format"})
      {:error, :limit_exceeded} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Bookmark limit exceeded"})
      {:error, :duplicate} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Bookmark already exists"})
      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to create bookmark"})
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "URL parameter is required"})
  end

  def show(conn, %{"url" => url}) do
    try do
      case :ets.lookup(@bookmark_table, url) do
        [{^url, _}] ->
          conn
          |> put_status(:ok)
          |> json(%{message: "Bookmark found", url: url})

        _ ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "Bookmark not found"})
      end
    catch
      :error, :badarg ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Bookmark storage unavailable"})
    end
  end

  def update(conn, %{"url" => url, "new_url" => new_url}) do
    with {:ok, _} <- validate_url(new_url),
         {:ok, _} <- check_bookmark_exists(url),
         :ok <- atomic_update(url, new_url) do
      conn
      |> put_status(:ok)
      |> json(%{message: "Bookmark updated", url: new_url})
    else
      {:error, :invalid_url} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid URL format"})
      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Bookmark not found"})
      {:error, :duplicate} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "New URL already exists"})
      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to update bookmark"})
    end
  end

  def delete(conn, %{"url" => url}) do
    try do
      case :ets.lookup(@bookmark_table, url) do
        [{^url, _}] ->
          :ets.delete(@bookmark_table, url)
          conn
          |> put_status(:no_content)
          |> send_resp(:no_content, "")

        _ ->
          conn
          |> put_status(:not_found)
          |> json(%{error: "Bookmark not found"})
      end
    catch
      :error, :badarg ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Bookmark storage unavailable"})
    end
  end

  # Private helper functions

  defp validate_url(url) do
    if Regex.match?(@url_regex, url) do
      {:ok, url}
    else
      {:error, :invalid_url}
    end
  end

  defp check_bookmark_limit do
    try do
      if :ets.info(@bookmark_table, :size) < @max_bookmarks do
        {:ok, :within_limit}
      else
        {:error, :limit_exceeded}
      end
    catch
      :error, :badarg -> {:error, :storage_unavailable}
    end
  end

  defp check_bookmark_exists(url) do
    try do
      case :ets.lookup(@bookmark_table, url) do
        [{^url, _}] -> {:ok, :exists}
        _ -> {:error, :not_found}
      end
    catch
      :error, :badarg -> {:error, :storage_unavailable}
    end
  end

  defp insert_bookmark(url) do
    try do
      case :ets.lookup(@bookmark_table, url) do
        [] ->
          :ets.insert(@bookmark_table, {url, url})
          {:ok, :inserted}
        _ ->
          {:error, :duplicate}
      end
    catch
      :error, :badarg -> {:error, :storage_unavailable}
    end
  end

  defp atomic_update(old_url, new_url) do
    try do
      # Since ETS doesn't support transactions, we'll use a synchronized operation
      case {:ets.lookup(@bookmark_table, old_url), :ets.lookup(@bookmark_table, new_url)} do
        {[{^old_url, _}], []} ->
          :ets.delete(@bookmark_table, old_url)
          :ets.insert(@bookmark_table, {new_url, new_url})
          :ok
        {[], _} ->
          {:error, :not_found}
        {_, [_|_]} ->
          {:error, :duplicate}
      end
    catch
      :error, :badarg -> {:error, :storage_unavailable}
    end
  end
end