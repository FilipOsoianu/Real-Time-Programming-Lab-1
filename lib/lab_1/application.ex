defmodule Lab1.Application do
  use Application

  def start(_type, _args) do
    children = [
      %{
        id: DataFlow,
        start: {DataFlow, :start_link, [""]}
      },
      %{
        id: Router,
        start: {Router, :start_link, [""]}
      },
      %{
        id: Aggregator,
        start: {Aggregator, :start_link, [""]}
      },
      {
        DynSupervisor,
        []
      },
      %{
        id: Input,
        start: {Input, :start_link, []}
      },
      %{
        id: FetchSSE,
        start: {FetchSSE, :start_link, ["http://localhost:4000/iot"]}
      }
    ]

    opts = [strategy: :one_for_one, name: MainSupervisor]
    Supervisor.start_link(children, opts)
  end
end
