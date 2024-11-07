defmodule Nexus.BrowserEngine do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      tabs: %{},
      active_tab: nil,
      settings: load_default_settings()
    }}
  end

  def handle_call({:create_tab, url}, _from, state) do
    tab_id = generate_tab_id()
    new_tab = %{
      id: tab_id,
      url: url,
      title: "New Tab",
      loading: true
    }
    
    new_state = put_in(state.tabs[tab_id], new_tab)
    {:reply, {:ok, new_tab}, new_state}
  end

  defp load_default_settings do
    %{
      search_engine: "https://www.google.com/search?q=",
      enable_ad_blocking: true,
      enable_tracking_protection: true,
      theme: "system",
      download_path: nil
    }
  end

  defp generate_tab_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
end
