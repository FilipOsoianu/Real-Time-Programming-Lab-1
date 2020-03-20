defmodule Root do
  # recv data from Fetch module
  def setup do
    number = 0
    start_time = Time.utc_now()
    counter = 0
    recv(start_time, number, counter)
  end

  def recv(start_time, number, counter) do
    if number == 1000 do
      final_time = Time.utc_now()
      diff = Time.diff(final_time, start_time, :millisecond)
      IO.puts("timeeeee")
      IO.inspect(diff)
      setup()
    else
      number = number + 1
      receive do
        {:data, msg} -> msg_operations(msg, number, start_time, counter)
        _ -> IO.puts("No match!")
      end
    end
  end

  # work with msg
  def msg_operations(msg, number, start_time, counter) do
    pids_list = DynSupervisor.pid_children()
    IO.inspect(DynSupervisor.count_children())

    if DynSupervisor.count_children()[:active] < 50000 do
      create_worker(msg)
      recv(start_time, number, counter)
    else
      counter = counter + 1
      if counter < length(pids_list) do
        DynSupervisor.push_message_to_worker(Enum.at(pids_list, counter), msg)
        recv(start_time, number, counter)
      else
        counter = 0
        recv(start_time, number, counter)
      end
    end
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
