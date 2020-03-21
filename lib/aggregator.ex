defmodule Aggregator do
  def start_link do
    # Process.sleep(100)
    IO.puts("dadada")
    counter = 0
    recv(counter)
  end

  def recv(counter) do
    pids_list = DynSupervisor.pid_children()
    msg_operations(pids_list, counter)
  end

  def msg_operations(pids_list, counter) do
    if length(pids_list) > 0 do
      pop_message(pids_list, counter)
    end

    recv(counter)
  end

  def pop_message(pids_list, counter) do
    Process.sleep(100)

    # IO.inspect(pids_list)
    # IO.inspect(counter)
    # IO.inspect(length(pids_list))

    if counter < length(pids_list) - 1 do
      # DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter))
      # IO.inspect(DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter)))
      # IO.inspect(Enum.at(pids_list, counter))
      counter = counter + 1
      recv(counter)
    else
      counter = 0
      IO.inspect(DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter)))
      # DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter))
      # IO.inspect(Enum.at(pids_list, counter))
      recv(counter)
    end
  end
end
