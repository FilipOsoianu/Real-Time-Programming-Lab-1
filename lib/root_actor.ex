defmodule Root do
  # recv data from Fetch module
  def recv(pids_list) do

    receive do
      {:data, msg} -> msg_operations(msg, pids_list)
      _ -> IO.puts("No match!")
    end
  end

  # work with msg
  def msg_operations(msg, pids_list) do

    if DynSupervisor.count_children()[:active] < 1 do
      {state, pid} = create_worker(msg)
      pids_list = add_pid_in_pids_list(pid, pids_list)
      recv(pids_list)

    else
      [head | tail] = pids_list
      DynSupervisor.push_message_to_worker(head, msg)
      recv(pids_list)
    end
  end

  defp get_pids_list_size(pids_list) do
    length(pids_list)
  end

  defp add_pid_in_pids_list(pid, pids_list) do
    [pid | pids_list]
  end

  defp create_worker(msg) do
    DynSupervisor.add_worker(msg)
  end

  defp remove_worker(pid) do
    DynSupervisor.remove_worker(pid)
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
