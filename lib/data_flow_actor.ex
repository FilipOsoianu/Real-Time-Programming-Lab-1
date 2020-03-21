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
  def handle_call({:recommend_max_workers, msg}, _from, state) do
    {:reply, msg, state}
  end
end
