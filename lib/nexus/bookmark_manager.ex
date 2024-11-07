defmodule Nexus.BookmarkManager do
  use GenServer
  require Logger

  defmodule Bookmark do
    defstruct [:id, :url, :title, :favicon, :folder, :tags, created_at: DateTime.utc_now()]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    bookmarks = load_bookmarks() || %{}
    {:ok, %{bookmarks: bookmarks}}
  end

  def handle_call(:get_bookmarks, _from, state) do
    {:reply, state.bookmarks, state}
  end

  def handle_call({:add_bookmark, params}, _from, state) do
    bookmark_id = generate_id()
    bookmark = %Bookmark{
      id: bookmark_id,
      url: params.url,
      title: params.title,
      favicon: params.favicon,
      folder: params.folder,
      tags: params.tags || []
    }
    
    new_state = put_in(state.bookmarks[bookmark_id], bookmark)
    save_bookmarks(new_state.bookmarks)
    
    {:reply, {:ok, bookmark}, new_state}
  end

  def handle_cast({:remove_bookmark, id}, state) do
    {_bookmark, new_bookmarks} = Map.pop(state.bookmarks, id)
    new_state = %{state | bookmarks: new_bookmarks}
    save_bookmarks(new_bookmarks)
    {:noreply, new_state}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(16) |> Base.encode16()

  defp load_bookmarks do
    case File.read("bookmarks.json") do
      {:ok, content} -> Jason.decode!(content)
      {:error, _} -> nil
    end
  end

  defp save_bookmarks(bookmarks) do
    File.write!("bookmarks.json", Jason.encode!(bookmarks))
  end
end
