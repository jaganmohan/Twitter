defmodule TwitterClone.Appserver do
    use Supervisor

    def start_link(opts) do
        
    end

    def init(:ok) do
        children = [
            {TwitterClone.Datastore, name: Datastore},
            {TwitterClone.Server, name: Server}
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end