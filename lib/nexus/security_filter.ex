defmodule Nexus.SecurityFilter do
  use GenServer
  require Logger

  defmodule SecurityRule do
    defstruct [:type, :pattern, :level, :action]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      rules: load_security_rules(),
      blocked_domains: MapSet.new(),
      suspicious_ips: MapSet.new(),
      last_update: nil
    }}
  end

  def handle_call({:check_url, url}, _from, state) do
    result = analyze_url(url, state)
    {:reply, result, state}
  end

  def handle_cast({:update_rules, new_rules}, state) do
    {:noreply, %{state | rules: new_rules, last_update: DateTime.utc_now()}}
  end

  defp analyze_url(url, state) do
    cond do
      is_blocked_domain?(url, state) ->
        {:block, "Domain is blocked"}
      is_suspicious_ip?(url, state) ->
        {:block, "Suspicious IP address"}
      has_security_violation?(url, state) ->
        {:block, "Security rule violation"}
      true ->
        :allow
    end
  end

  defp is_blocked_domain?(url, state) do
    domain = extract_domain(url)
    MapSet.member?(state.blocked_domains, domain)
  end

  defp is_suspicious_ip?(url, state) do
    ip = extract_ip(url)
    MapSet.member?(state.suspicious_ips, ip)
  end

  defp has_security_violation?(url, state) do
    Enum.any?(state.rules, fn rule ->
      matches_security_rule?(url, rule)
    end)
  end

  defp matches_security_rule?(url, rule) do
    case rule.type do
      :pattern -> Regex.match?(rule.pattern, url)
      :domain -> url |> extract_domain() |> String.contains?(rule.pattern)
      :protocol -> url |> URI.parse() |> Map.get(:scheme) == rule.pattern
    end
  end

  defp extract_domain(url) do
    url |> URI.parse() |> Map.get(:host, "")
  end

  defp extract_ip(url) do
    # Implement IP extraction logic
    ""
  end

  defp load_security_rules do
    [
      %SecurityRule{
        type: :pattern,
        pattern: ~r/\.(exe|dll|bat)$/i,
        level: :high,
        action: :block
      },
      %SecurityRule{
        type: :protocol,
        pattern: "http",
        level: :medium,
        action: :warn
      }
    ]
  end
end
