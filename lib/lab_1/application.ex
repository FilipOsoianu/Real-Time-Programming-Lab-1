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
       %{
        id: Aggregator,
        start: {Aggregator, :start_link, []}
      },
       %{
        id: DataFlow,
        start: {DataFlow, :start_link, ["da"]}
      },
      %{
        id: Router,
        start: {Router, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)
  end
end
