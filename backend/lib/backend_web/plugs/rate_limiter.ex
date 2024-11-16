defmodule BackendWeb.RateLimiter do
  @moduledoc """
  A plug that implements rate limiting using ETS tables.
  Limits requests based on IP address.
  """

  import Plug.Conn
  require Logger

  @behaviour Plug

  # 100 requests per minute
  @max_requests 100
  @timeframe 60_000

  def init(opts), do: opts

  def call(conn, _opts) do
    case check_rate_limit(conn) do
      :ok ->
        conn

      :rate_limited ->
        conn
        |> put_status(:too_many_requests)
        |> Phoenix.Controller.json(%{error: "Rate limit exceeded. Please try again later."})
        |> halt()
    end
  end

  defp check_rate_limit(conn) do
    ip = get_client_ip(conn)
    now = System.system_time(:millisecond)
    key = "rate_limit:#{ip}"

    try do
      case :ets.lookup(:rate_limiter, key) do
        [] ->
          :ets.insert(:rate_limiter, {key, [now]})
          :ok

        [{^key, timestamps}] ->
          clean_timestamps = Enum.filter(timestamps, &(&1 > now - @timeframe))

          cond do
            length(clean_timestamps) >= @max_requests ->
              :rate_limited

            true ->
              :ets.insert(:rate_limiter, {key, [now | clean_timestamps]})
              :ok
          end
      end
    catch
      :error, :badarg ->
        Logger.error("Rate limiter ETS table not available")
        :ok
    end
  end

  defp get_client_ip(conn) do
    forwarded_for = get_req_header(conn, "x-forwarded-for")

    case forwarded_for do
      [ip | _] -> ip
      _ -> to_string(:inet_parse.ntoa(conn.remote_ip))
    end
  end
end
