defmodule BackendWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        measurement: :duration,
        description: "The time it takes to stop the endpoint.",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        measurement: :duration,
        description: "The time it takes to dispatch a request.",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # VM Metrics
      last_value("vm.memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.total_bytes", unit: :byte),
      last_value("vm.memory.binary", unit: {:byte, :kilobyte}),
      last_value("vm.memory.ets", unit: {:byte, :kilobyte}),
      last_value("vm.memory.processes", unit: {:byte, :kilobyte}),
      last_value("vm.system_memory.total", unit: {:byte, :kilobyte}),
      last_value("vm.system_memory.free", unit: {:byte, :kilobyte}),

      # Logger Metrics
      counter("logger.log", tags: [:level]),
      counter("logger.error", tags: [:level])
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {BackendWeb, :count_users, []}
    ]
  end
end
