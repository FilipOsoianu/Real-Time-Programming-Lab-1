defmodule FetchSSE do
  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())

    router = spawn_link(Router, :start_link, [])
    data_flow = GenServer.start_link(DataFlow, [])

    :ets.new(:buckets_registry, [:named_table])
    :ets.insert(:buckets_registry, {"router", router})
    :ets.insert(:buckets_registry, {"data_flow", data_flow})

    recv()
  end

  def recv do
    receive do
      msg -> msg_operations(msg)
    end
  end

  def msg_operations(msg) do
    [{_id, router_pid}] = :ets.lookup(:buckets_registry, "router")
    [{_id,{:ok, data_flow_pid }}]= :ets.lookup(:buckets_registry, "data_flow")
    IO.inspect(    GenServer.call(data_flow_pid, {:recommend_max_workers, msg}))
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
