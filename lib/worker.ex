defmodule Worker do
  use GenServer, restart: :permanent

  def start_link(msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  # Callbacks 
   @impl true
  def init(msg) do
    # Logger.info("Starting #{inspect(name)}")
    IO.inspect("start")
    # IO.inspect(json_parse(msg))
    {:ok, self()}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    # IO.inspect(json_parse(element))
    # IO.inspect(element)
    IO.inspect("reuse")
    json = json_parse(element)
    {:noreply, state}
  end

  def json_parse(msg) do
    msg_data = Jason.decode!(msg.data)
    msg_data["message"]
  end
end
