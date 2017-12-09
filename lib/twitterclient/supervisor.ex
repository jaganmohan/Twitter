defmodule TwitterClient.Supervisor do
    use Supervisor

    def start_link(opts) do
        IO.puts("Starting Simulator .....")
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do

        cookie = Application.get_env(:twitter, :cookie)        
        node_name = :AppSimulator@localhost
        {:ok, nodePID} = Node.start(node_name, :shortnames)
        Node.set_cookie(node(), cookie)
        Node.connect(:AppServer@localhost);
        :global.sync()
        IO.inspect(:global.registered_names())

        #IO.inspect(self())
        #:global.register_name(:AppServer, self())
        #Supervisor.child_spec
        children = [
            {TwitterClient.Simulator, name: :Simulator},
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end