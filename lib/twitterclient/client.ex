defmodule TwitterClient.Client do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(args) do
        #IO.puts("Initializing Client .....#{inspect(self())}")
        #TODO define state
        :global.sync()
        server = :global.whereis_name(:Server)
        retweetDist = [0,0,1,0,1,0,0,0,1,0]
        {:ok, %{"server": server, "retweetDist": retweetDist}}
    end

    def handle_cast({:dist, follower, tweet}, state) do
        # TODO log msg: user tweet when user is live
        IO.puts("[#{follower}] Tweet by #{tweet.origin}: #{tweet.msg}")
        #Re-tweet optional
        #if Enum.random(state.retweetDist) == 1 do
        #    GenServer.cast(self(), {:publishTweet, follower, tweet})
        #end
        {:noreply, state}
    end

    def handle_cast({:publishTweet, user, tweet}, state) do
        # publish when user is logged in
        # TODO construct tweet randomly and call this method from elsewhere
        GenServer.cast(state.server, {:publish, user, tweet})
        {:noreply, state}
    end

    def queryTweets(query) do
        # construct query if query is nil
        query = 
        if query == nil do
            %Util.Query{}
        end
        GenServer.call(Server, {:query, query})
    end
end