defmodule NexusWeb.BrowserChannel do
  use Phoenix.Channel
  alias Nexus.BrowserEngine
  alias Nexus.TabManager
  alias Nexus.BookmarkManager

  def join("browser:" <> user_id, _params, socket) do
    {:ok, assign(socket, :user_id, user_id)}
  end

  def handle_in("new_tab", %{"url" => url}, socket) do
    case TabManager.create_tab(url) do
      {:ok, tab} ->
        broadcast!(socket, "tab_created", tab)
        {:reply, {:ok, tab}, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("navigate", %{"tab_id" => tab_id, "url" => url}, socket) do
    case TabManager.navigate_tab(tab_id, url) do
      {:ok, tab} ->
        broadcast!(socket, "tab_updated", tab)
        {:reply, {:ok, tab}, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("add_bookmark", params, socket) do
    case BookmarkManager.add_bookmark(params) do
      {:ok, bookmark} ->
        broadcast!(socket, "bookmark_added", bookmark)
        {:reply, {:ok, bookmark}, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end
end
