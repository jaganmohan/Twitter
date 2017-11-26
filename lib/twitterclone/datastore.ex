defmodule TwitterClone.Datastore do
    use GenServer

    def start_link(opts) do
        IO.puts("Initializing Datastore .....")        
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        clientsTbl = :ets.new(:clients, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        tweetsTbl = :ets.new(:tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        clientTweets = :ets.new(:client_tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        tables = %{"clientsTbl": clientsTbl, "tweetsTbl": tweetsTbl, "clientTweets": clientTweets}
        {:ok, tables}
    end

    def handle_cast({:register, user}, tables) do
        clientsTbl = tables["clientsTbl"]
        :ets.insert(:clients, {user, []})
        {:noreply, tables}
    end

    def handle_cast({:setFollowers, user, followers}, tables) do
        :ets.insert(:clients, {user, followers})
        {:noreply, tables}
    end

    def handle_call({:getFollowers, user}, from, tables) do
        clientsTbl = tables["clientsTbl"]
        # TODO get followers
        followers = []
        {:reply, followers, tables}
    end

    def handle_call({:getAllTweets, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        tweets = []
        {:reply, tweets, tables}
    end

    def handle_call({:getHashTagTweets, tags, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        tweets = []
        {:reply, tweets, tables}
    end

    def handle_call({:getMentionsTweets, tags, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        tweets = []
        {:reply, tweets, tables}
    end

    def handle_cast({:putTweet, tweet}, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        {:noreply, tables}
    end

    def handle_cast({:addFollowers, user}, tables) do
        clientsTbl = tables["clientsTbl"]
        # TODO add followers
        {:noreply, tables}
    end
    
end