defmodule Nexus.HistoryManager do
  use GenServer
  require Logger

  defmodule HistoryEntry do
    defstruct [:id, :url, :title, :favicon, visited_at: DateTime.utc_now()]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    history = load_history() || []
    {:ok, %{history: history}}
  end

  def handle_call(:get_history, _from, state) do
    {:reply, state.history, state}
  end

  def handle_call({:add_entry, params}, _from, state) do
    entry = %HistoryEntry{
      id: generate_id(),
      url: params.url,
      title: params.title,
      favicon: params.favicon
    }
    
    new_history = [entry | state.history]
    new_state = %{state | history: new_history}
    save_history(new_history)
    
    {:reply, {:ok, entry}, new_state}
  end

  def handle_cast(:clear_history, _state) do
    save_history([])
    {:noreply, %{history: []}}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()

  defp load_history do
    case File.read("history.json") do
      {:ok, content} -> Jason.decode!(content)
      {:error, _} -> nil
    end
  end

  defp save_history(history) do
    File.write!("history.json", Jason.encode!(history))
  end
end
