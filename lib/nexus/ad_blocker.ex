defmodule Nexus.AdBlocker do
  use GenServer
  require Logger

  defmodule Rule do
    defstruct [:pattern, :type, :action]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      rules: load_rules(),
      cache: :ets.new(:ad_blocker_cache, [:set, :private])
    }}
  end

  def handle_call({:should_block?, url}, _from, state) do
    case check_cache(state.cache, url) do
      {:ok, result} ->
        {:reply, result, state}
      :miss ->
        result = check_rules(url, state.rules)
        cache_result(state.cache, url, result)
        {:reply, result, state}
    end
  end

  def handle_cast({:update_rules, new_rules}, state) do
    :ets.delete_all_objects(state.cache)
    {:noreply, %{state | rules: new_rules}}
  end

  defp check_cache(cache, url) do
    case :ets.lookup(cache, url) do
      [{^url, result}] -> {:ok, result}
      [] -> :miss
    end
  end

  defp cache_result(cache, url, result) do
    :ets.insert(cache, {url, result})
  end

  defp check_rules(url, rules) do
    Enum.any?(rules, fn rule ->
      Regex.match?(rule.pattern, url) and rule.action == :block
    end)
  end

  defp load_rules do
    # Load from file or default rules
    [
      %Rule{
        pattern: ~r/ads?[\.-]/, 
        type: :pattern,
        action: :block
      },
      %Rule{
        pattern: ~r/analytics/, 
        type: :pattern,
        action: :block
      },
      %Rule{
        pattern: ~r/tracker/, 
        type: :pattern,
        action: :block
      }
    ]
  end
end
