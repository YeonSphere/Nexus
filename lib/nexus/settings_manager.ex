defmodule Nexus.SettingsManager do
  use GenServer
  require Logger

  @default_settings %{
    search_engine: "https://search.brave.com/search?q=",
    ad_blocking: true,
    tracking_protection: true,
    theme: "system",
    font_size: 16,
    javascript_enabled: true,
    cookies_enabled: true,
    default_download_path: nil,
    homepage: "https://yeonsphere.github.io/",
    sync_enabled: false
  }

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    settings = load_settings() || @default_settings
    {:ok, settings}
  end

  def handle_call(:get_settings, _from, settings) do
    {:reply, settings, settings}
  end

  def handle_cast({:update_settings, new_settings}, _state) do
    merged_settings = Map.merge(@default_settings, new_settings)
    save_settings(merged_settings)
    {:noreply, merged_settings}
  end

  defp load_settings do
    case File.read("settings.json") do
      {:ok, content} -> Jason.decode!(content)
      {:error, _} -> nil
    end
  end

  defp save_settings(settings) do
    File.write!("settings.json", Jason.encode!(settings))
  end
end
