
defmodule Lab1.Application do
  use Application

  @registry :workers_registry

  def start(_type, _args) do
    children = [
      {
        Registry,
        [keys: :unique, name: @registry]
      },
      {
        DynSupervisor,
        []
      },
      %{
        id: FetchSSE,
        start: {FetchSSE, :start_link, ["http://localhost:4000/iot"]}
      },
      %{
        id: Router,
        start: {Router, :recv, [[]]}
      },
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end