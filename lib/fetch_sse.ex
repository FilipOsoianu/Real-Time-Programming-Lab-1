defmodule FetchSSE do
  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())
    {:ok, data_flow_pid} = GenServer.start_link(DataFlow, [])

    router_pid = spawn_link(Router, :start_link, [])

    :ets.new(:buckets_registry, [:named_table])
    :ets.insert(:buckets_registry, {"router_pid", router_pid})
    :ets.insert(:buckets_registry, {"data_flow_pid", data_flow_pid})

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
    # IO.inspect(data_flow_pid)
    GenServer.cast(data_flow_pid, {:push, msg})
    send(router_pid, {:data, msg})

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
