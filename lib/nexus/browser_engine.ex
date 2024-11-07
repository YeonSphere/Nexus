defmodule Nexus.BrowserEngine do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      tabs: %{},
      settings: load_default_settings(),
      history: [],
      downloads: []
    }}
  end

  def handle_call({:create_tab, url}, _from, state) do
    tab_id = generate_tab_id()
    new_tab = %{
      id: tab_id,
      url: url,
      title: "New Tab",
      status: :loading,
      created_at: DateTime.utc_now()
    }
    
    new_state = put_in(state.tabs[tab_id], new_tab)
    {:reply, {:ok, new_tab}, new_state}
  end

  def handle_call({:navigate, tab_id, url}, _from, state) do
    case state.tabs[tab_id] do
      nil ->
        {:reply, {:error, :tab_not_found}, state}
      tab ->
        updated_tab = %{tab | url: url, status: :loading}
        new_state = put_in(state.tabs[tab_id], updated_tab)
        {:reply, {:ok, updated_tab}, new_state}
    end
  end

  defp load_default_settings do
    %{
      search_engine: "https://www.google.com/search?q=",
      ad_blocking: true,
      tracking_protection: true,
      theme: "system",
      download_path: nil
    }
  end

  defp generate_tab_id do
    :crypto.strong_rand_bytes(16) |> Base.encode16()
  end
end
