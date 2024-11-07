defmodule Nexus.NetworkInterceptor do
  use GenServer
  require Logger

  defmodule Request do
    defstruct [:url, :method, :headers, :body, :timestamp]
  end

  defmodule Response do
    defstruct [:status, :headers, :body, :timestamp]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{
      interceptors: [
        &Nexus.AdBlocker.intercept/1,
        &Nexus.SecurityFilter.intercept/1,
        &Nexus.PrivacyFilter.intercept/1
      ],
      requests: []
    }}
  end

  def handle_call({:intercept, request}, _from, state) do
    case apply_interceptors(request, state.interceptors) do
      {:block, reason} ->
        Logger.info("Blocked request to #{request.url}: #{reason}")
        {:reply, {:block, reason}, state}
      :allow ->
        new_state = %{state | requests: [request | state.requests]}
        {:reply, :allow, new_state}
    end
  end

  defp apply_interceptors(request, interceptors) do
    Enum.reduce_while(interceptors, :allow, fn interceptor, _acc ->
      case interceptor.(request) do
        :allow -> {:cont, :allow}
        {:block, reason} -> {:halt, {:block, reason}}
      end
    end)
  end

  def handle_cast({:log_response, request_id, response}, state) do
    Logger.debug("Response for #{request_id}: #{response.status}")
    {:noreply, state}
  end

  def handle_call(:get_request_log, _from, state) do
    {:reply, Enum.reverse(state.requests), state}
  end
end
