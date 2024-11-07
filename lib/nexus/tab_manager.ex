defmodule Nexus.TabManager do
  use GenServer
  require Logger

  defmodule Tab do
    defstruct [:id, :url, :title, :favicon, :loading, :history, created_at: DateTime.utc_now()]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{tabs: %{}, active_tab: nil}}
  end

  def handle_call(:get_tabs, _from, state) do
    {:reply, state.tabs, state}
  end

  def handle_call(:get_active_tab, _from, state) do
    {:reply, state.active_tab, state}
  end

  def handle_call({:create_tab, url}, _from, state) do
    tab_id = generate_tab_id()
    new_tab = %Tab{
      id: tab_id,
      url: url,
      title: "New Tab",
      loading: true,
      history: [url]
    }
    
    new_state = state
      |> put_in([:tabs, tab_id], new_tab)
      |> Map.put(:active_tab, tab_id)
    
    {:reply, {:ok, new_tab}, new_state}
  end

  def handle_cast({:close_tab, tab_id}, state) do
    {_tab, new_tabs} = Map.pop(state.tabs, tab_id)
    new_state = %{state | tabs: new_tabs}
    new_state = if state.active_tab == tab_id do
      %{new_state | active_tab: get_last_tab_id(new_tabs)}
    else
      new_state
    end
    {:noreply, new_state}
  end

  defp generate_tab_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
  
  defp get_last_tab_id(tabs) do
    case Map.keys(tabs) do
      [] -> nil
      keys -> List.last(keys)
    end
  end
end
