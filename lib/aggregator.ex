defmodule Aggregator do
  def start_link do
    Process.sleep(1000)
    IO.puts("dadada")
    counter = 0
    recv(counter)
  end

  def recv(counter) do
    pop_message(counter)
  end

  def pop_message(counter) do
    Process.sleep(20)
    pids_list = DynSupervisor.pid_children()

    # IO.inspect(pids_list)

    if length(pids_list) > 0 do
      # IO.inspect(pids_list)
      # IO.inspect(counter)
      # IO.inspect(length(pids_list))

      if counter < length(pids_list) - 1 do
        DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter))
        # IO.inspect(DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter)))
        # IO.inspect(Enum.at(pids_list, counter))
        counter = counter + 1
        recv(counter)
      else
        counter = 0
        # IO.inspect(DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter)))
        DynSupervisor.pop_message_to_worker(Enum.at(pids_list, counter))
        # IO.inspect(Enum.at(pids_list, counter))
        recv(counter)
      end
    end
  end
end
