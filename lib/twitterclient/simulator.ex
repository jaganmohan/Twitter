defmodule TwitterClient.Simulator do
    use Task, restart: :permanent
    # If you own the given module, please define a child_spec/1 function
    # that receives an argument and returns a child specification as a map.
    # For example:
    
    #     def child_spec(opts) do
    #       %{
    #         id: __MODULE__,
    #         start: {__MODULE__, :start_link, [opts]},
    #         type: :worker,
    #         restart: :permanent,
    #         shutdown: 500
    #       }
    #     end
    
    # Note that "use Agent", "use GenServer" and so on automatically define
    # this function for you.
    
    # However, if you don't own the given module and it doesn't implement
    # child_spec/1, instead of passing the module name directly as a supervisor
    # child, you will have to pass a child specification as a map:
    
    #     %{
    #       id: TwitterClient.Simulator,
    #       start: {TwitterClient.Simulator, :start_link, [arg1, arg2]}
    #     }

    def start_link(opts) do
        cookie = Application.get_env(:twitter, :cookie)        
        node_name = "NodeSimulator"
        node_name = String.to_atom(node_name)
        {:ok, nodePID} = Node.start(node_name, :shortnames)
        Node.set_cookie(node(), cookie)
        Task.start_link(__MODULE__, :init, opts)
    end

    # ets table
    def init(args) do
        IO.puts("Initializing simulator...")
        clientsTbl = :ets.new(:clients_siml, [:set, :private, :named_table, 
        read_concurrency: true])
        numClients = Application.get_env(:twitter, :num_clients)
        beta = Application.get_env(:twitter, :beta)

        # create N client actors
        # get N from application config
        dist = zipf(numClients)
        IO.puts("zipf distribution: #{inspect(dist)}")

        for i <- 1..numClients do
            client_name = "User#{i}"
            client_name = String.to_atom(client_name)
            clientPID = TwitterClient.Client.start_link([client_name])

            # connect to server node and register client process
            #GenServer.cast(Server, {:register, client_name})

            :ets.insert(:clients_siml, {client_name, clientPID, dist[i]})
        end

        #creating total num of followers
        v = 0.9*numClients |> round
        v = Enum.random(v..numClients)
        total_followers = v/dist[1] |> round
        IO.puts("Total number of followers: #{total_followers}")

        IO.puts("Sum of zipf probabilities: #{Enum.reduce(dist, 0, fn({k, v}, acc) -> v + acc end)}")
        createFollowers(dist, numClients, total_followers)
    end

    def zipf(n, alpha \\ 1) do
        c = 1/Enum.reduce(1..n, 0, fn (x, acc) -> 
            acc = acc + 1/:math.pow(x,alpha) end)
        Enum.reduce(1..n, %{}, fn (x, acc) -> 
            acc = Map.put(acc, x, c/:math.pow(x,alpha)) end)
    end

    def createFollowers(dist, numClients, total_followers) do
        clients = Enum.map(1..numClients,fn x -> "User#{x}" end)
        for i <- 1..numClients do
            users = List.delete_at(clients, i-1)
            followers = Enum.take_random(users, dist[i]*total_followers|>round)
            IO.inspect("User{i} followers: #{inspect(followers)}")
            #GenServer.cast(Server, {:setFollowers, "User#{i}", followers})
        end
    end

    #write test cases to simulate the functions
    
end