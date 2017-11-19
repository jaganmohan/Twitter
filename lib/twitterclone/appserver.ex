defmodule TwitterClone.Appserver do
    use Supervisor

    def start_link(opts) do
        IO.puts("Starting Twitter AppServer")
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        children = [
            {TwitterClone.Datastore, name: Datastore},
            {TwitterClone.Server, name: Server}
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end