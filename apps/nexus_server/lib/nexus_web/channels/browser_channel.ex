defmodule NexusWeb.BrowserChannel do
  use NexusWeb, :channel
  alias Nexus.BrowserEngine
  alias Phoenix.Socket.Broadcast

  def join("browser:" <> user_id, _params, socket) do
    {:ok, assign(socket, :user_id, user_id)}
  end

  def handle_in("new_tab", %{"url" => url}, socket) do
    case GenServer.call(BrowserEngine, {:create_tab, url}) do
      {:ok, tab} ->
        broadcast!(socket, "tab_created", tab)
        {:reply, {:ok, tab}, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end

  def handle_in("update_settings", settings, socket) do
    case GenServer.call(BrowserEngine, {:update_settings, settings}) do
      :ok ->
        broadcast!(socket, "settings_updated", settings)
        {:reply, :ok, socket}
      {:error, reason} ->
        {:reply, {:error, reason}, socket}
    end
  end
end
