defmodule Nexus.DownloadManager do
  use GenServer
  require Logger

  defmodule Download do
    defstruct [:id, :url, :filename, :path, :size, :progress, :status, 
              started_at: DateTime.utc_now(), completed_at: nil]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{downloads: %{}, active_downloads: %{}}}
  end

  def handle_call(:get_downloads, _from, state) do
    {:reply, state.downloads, state}
  end

  def handle_call({:start_download, url, path}, _from, state) do
    download_id = generate_id()
    download = %Download{
      id: download_id,
      url: url,
      path: path,
      status: :starting,
      progress: 0
    }
    
    new_state = put_in(state.downloads[download_id], download)
    |> put_in([:active_downloads, download_id], download)
    
    Task.start(fn -> process_download(download) end)
    
    {:reply, {:ok, download}, new_state}
  end

  def handle_cast({:update_progress, id, progress}, state) do
    new_state = update_in(state.downloads[id], &(%{&1 | progress: progress}))
    {:noreply, new_state}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()

  defp process_download(download) do
    # Implement actual download logic here
    # This would handle the actual file download, progress updates, etc.
  end
end
