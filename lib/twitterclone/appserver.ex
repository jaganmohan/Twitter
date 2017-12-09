defmodule TwitterClone.Appserver do
    use Supervisor

    def start_link(opts) do
        IO.puts("Starting Twitter AppServer")
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do

        cookie = Application.get_env(:twitter, :cookie)        
        node_name = :AppServer@localhost
        {:ok, nodePID} = Node.start(node_name, :shortnames)
        Node.set_cookie(node(), cookie)

        children = [
            {TwitterClone.Datastore, name: :Datastore},
            {TwitterClone.Server, name: :Server}
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end