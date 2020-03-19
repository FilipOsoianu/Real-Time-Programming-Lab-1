defmodule Root do
  # recv data from Fetch module
  def recv() do
    receive do
      {:data, msg} -> msg_operations(msg)
      _ -> IO.puts("No match!")
    end
  end

  # work with msg
  def msg_operations(msg) do
    {state, pid} = DynSupervisor.add_worker(msg)
    IO.inspect(DynSupervisor.count_children())
    recv()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :recv, [opts]},
      type: :worker,
      restart: :permanent
    }
  end

end
