defmodule Worker do
  use GenServer, restart: :transient

  def start_link( msg) do
    GenServer.start_link(__MODULE__, msg)
  end

  # Callbacks
  def init(msg) do

    # Logger.info("Starting #{inspect(name)}")
    # IO.inspect(msg)
    IO.inspect(json_parse(msg))
    {:ok, self()}
  end


  def json_parse(msg) do
    msg_data = Jason.decode!(msg.data)
    msg_data["message"]
  end


end
