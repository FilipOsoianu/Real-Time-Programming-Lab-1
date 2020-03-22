defmodule FetchSSE do
  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())
    {:ok, router_pid} = GenServer.start_link(Router, [])
    {:ok, data_flow_pid} = GenServer.start_link(DataFlow, [])
    {:ok, aggregator_pid} = GenServer.start_link(Aggregator, [])

    :ets.new(:buckets_registry, [:named_table])
    :ets.insert(:buckets_registry, {"router_pid", router_pid})
    :ets.insert(:buckets_registry, {"data_flow_pid", data_flow_pid})
    :ets.insert(:buckets_registry, {"aggregator_pid", aggregator_pid})

    recv()
  end

  def recv do
    receive do
      msg -> msg_operations(msg)
    end
  end

  def msg_operations(msg) do
    [{_id, router_pid}] = :ets.lookup(:buckets_registry, "router_pid")
    [{_id, data_flow_pid}] = :ets.lookup(:buckets_registry, "data_flow_pid")
    [{_id, aggregator_pid}] = :ets.lookup(:buckets_registry, "aggregator_pid")
    GenServer.cast(data_flow_pid, :send_flow)
    GenServer.cast(router_pid, {:router, msg, aggregator_pid, data_flow_pid})
    recv()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent
    }
  end
end
