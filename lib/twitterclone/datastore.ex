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
        hashTweets = :ets.new(:hashtag_tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        mentionTweets = :ets.new(:mention_tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        tables = %{"clientsTbl": clientsTbl, "tweetsTbl": tweetsTbl, "clientTweets": clientTweets,
            "hashTweets": hashTweets, "mentionTweets": mentionTweets}
        {:ok, tables}
    end

    def handle_call({:register, user}, from, tables) do
        true = :ets.insert(:clients, {user, []})
        true = :ets.insert(:client_tweets, {user, []})
        {:reply, true, tables}
    end

    def handle_call({:addTweet, user, tweet}, from, tables) do
        {_, tweetList} = hd(:ets.lookup(:client_tweets, user))
        IO.inspect(tweetList)
        tweetList = [tweet.id | tweetList]
        :ets.insert(:client_tweets, {user, tweetList})

        for tag <- tweet.hashtags do
            tweetList = :ets.lookup(:hashtag_tweets, tag)
            if length(tweetList) == 0 do
                :ets.insert(:hashtag_tweets, {tag, tweet.id})
            else
                tweetList = hd(tweetList)
                {_, tweetList} = tweetList
                tweetList = [tweet.id | tweetList]
                :ets.insert(:hashtag_tweets, {tag, tweetList})
            end
        end

        for mention <- tweet.mentions do
            tweetList = :ets.lookup(:mention_tweets, mention)
            if length(tweetList) == 0 do
                :ets.insert(:mention_tweets, {mention, tweet.id})
            else
                tweetList = hd(tweetList)
                {_, tweetList} = tweetList
                tweetList = [tweet.id | tweetList]
                :ets.insert(:mention_tweets, {mention, mention})
            end
        end

        {:reply, :ok, tables}
    end

    def handle_cast({:setFollowers, user, followers}, tables) do
        :ets.insert(:clients, {user, followers})
        {:noreply, tables}
    end

    def handle_call({:getFollowers, user}, from, tables) do
        # TODO get followers
        {u, followers} = hd(:ets.lookup(:clients, user))
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