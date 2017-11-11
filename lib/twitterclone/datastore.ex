defmodule TwitterClone.Datastore do
    use GenServer

    def init() do
        clientsTbl = :ets.new(:clients, [set, private, named_table, 
            {write_concurrency, true}, {read_concurrency, true}])
        tweetsTbl = :ets.new(:tweets, [set, private, named_table, 
            {write_concurrency, true}, {read_concurrency, true}])
        clientTweets = :ets.new(:client_tweets, [set, private, named_table, 
            {write_concurrency, true}, {read_concurrency, true}])
        tables = %{"clientsTbl": clientsTbl, "tweetsTbl": tweetsTbl, "clientTweets": clientTweets}
        {:ok, tables}
    end

    def handle_call({:getFollowers, user}, from, tables) do
        clientsTbl = tables["clientsTbl"]
        # TODO get followers
        {:reply, followers, tables}
    end

    def handle_call({:getAllTweets, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        {:reply, tweets, tables}
    end

    def handle_call({:getHashTagTweets, tags, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
        {:reply, tweets, tables}
    end

    def handle_call({:getMentionsTweets, tags, user}, from, tables) do
        tweetsTbl = tables["tweetsTbl"]
        clientTweets = tables["clientTweets"]
        # TODO
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