defmodule Router do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_cast({:router, msg, aggregator_pid, data_flow_pid}, states) do
    recommend_max_workers = GenServer.call(data_flow_pid, :recommend_max_workers)
    pids_list = DynSupervisor.pid_children()
    if DynSupervisor.count_children()[:active] < recommend_max_workers do
      create_worker(msg)
    else
      if DynSupervisor.count_children()[:active] > recommend_max_workers do
        [head | tail] = pids_list
        DynSupervisor.remove_worker(head)
      end
    end

    #   if counter < length(pids_list) - 1 do
    #     counter = counter + 1
    #     compute_forecast(pids_list, counter, msg, aggregator_pid)
    #     recv(counter, aggregator_pid)
    #   else
    #     counter = 0
    # compute_forecast(pids_list, 1, msg, aggregator_pid)

    #     recv(counter, aggregator_pid)
    #   end
    # end

    {:noreply, []}
  end

  defp compute_forecast(pids_list, counter, msg, aggregator_pid) do
    DynSupervisor.compune_and_send_forecast(Enum.at(pids_list, counter), msg, aggregator_pid)
  end

  defp create_worker(msg) do
    DynSupervisor.create_worker(msg)
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
