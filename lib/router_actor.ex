defmodule Router do

  def start_link do
    {:ok, aggregator_pid} = GenServer.start_link(Aggregator, [])
    counter = 0
    
    recv(counter, aggregator_pid)
  end

  def recv(counter, aggregator_pid) do
    receive do
      {:data, msg} ->
        msg_operations(msg, counter, aggregator_pid)
      _ ->
        IO.puts("No match!")
    end
  end

  def msg_operations(msg, counter, aggregator_pid) do
    pids_list = DynSupervisor.pid_children()

    if DynSupervisor.count_children()[:active] < 2 do
      create_worker(msg)
    end

    if counter < length(pids_list) - 1 do
      counter = counter + 1
      DynSupervisor.compune_and_send_forecast(Enum.at(pids_list, counter), msg, aggregator_pid)
      recv(counter, aggregator_pid)
    else
      counter = 0
      DynSupervisor.compune_and_send_forecast(Enum.at(pids_list, counter), msg, aggregator_pid)
      recv(counter, aggregator_pid)

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
