defmodule DataFlow do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  @impl true
  def init(msg) do
    {:ok, msg}
  end

  @impl true
  def handle_call(:recommend_max_workers, _from, state) do
    [head | tail] = state
    {:reply, get_data_flow(head), tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    queue_lenght = Process.info(self())[:message_queue_len]

    IO.inspect(queue_lenght)
    {:noreply, [queue_lenght | state]}
  end

  def get_data_flow(head) do
    cond do
      head < 20 -> 1
      head > 20 && head < 60 -> 2
      head > 60 && head < 110 -> 3
      head > 110 && head < 160 -> 4
      head > 160 && head < 210 -> 5
      head > 210 && head < 260 -> 6
      head > 260 && head < 310 -> 7
      head > 310 && head < 360 -> 8
      head > 410 && head < 450 -> 9
      head > 450 -> 10
      true -> 10
    end
  end
end
