defmodule TwitterClient.Simulator do
    # ets table
    def init() do
        clientsTbl = :ets.new(:clients_siml, [:set, :private, :named_table, 
        read_concurrency: true])

        # create N client actors
        # get N from application config
        numClients = Application.get_env(:twitter, num_clients)
        
        for i in 1..numClients do
            client_name = "Client#{i}"
            client_name = String.to_atom(client_name)
            client_pid = TwitterClient.Client.start_link(client_name)
            :ets.insert({client_name, client_pid, 0})
        end

        # for zipf distribution
        # for each client number as rank lets create zipf probability distribution
        # randomly select num of followed numFollowed from 1..numClients
        # create list of followed by getting a client over created distribution
        # Remove the client from list of all client list and repeat above step
        # Continue above step until you create a list of numFollowed clients
        # for each client, then make a server call


    end

    def zipf(alpha, n) do
        c = 1/Enum.reduce(1..n, 0, fn x -> 
            acc = acc + 1/:math.pow(x,alpha) end)
        Enum.reduce(1..n, %{}, fn x -> 
            acc = Map.put(acc, x, c/:math.pow(x,alpha)) end)
    end

    def createFollowed(dist) do
       #also do a server call to create followers list on the go 
    end

    #write test cases to simulate the functions
    
end