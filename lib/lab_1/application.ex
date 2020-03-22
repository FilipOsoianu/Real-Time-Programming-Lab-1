defmodule Lab1.Application do
  use Application


  def start(_type, _args) do
    children = [
      {
        DynSupervisor,
        []
      },
      %{
        id: FetchSSE,
        start: {FetchSSE, :start_link, ["http://localhost:4000/iot"]}
      },
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end
