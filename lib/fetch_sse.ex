defmodule FetchSSE do
  def start_link(url) do
    {:ok, _pid} = EventsourceEx.new(url, stream_to: self())
    router_pid = spawn_link(Root, :recv, [])
    :ets.new(:buckets_registry, [:named_table])
    :ets.insert(:buckets_registry, {"router_pid", router_pid})
    recv()
  end

  def recv do
    receive do
      msg -> msg_operations(msg)
    end
  end

  def msg_operations(msg) do
    [{_id, root}] = :ets.lookup(:buckets_registry, "router_pid")
    send(root, {:data, msg})
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
