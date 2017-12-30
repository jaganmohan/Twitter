defmodule Twitterweb.Datastore do
    use GenServer

    def start_link() do
        IO.puts("Initializing Datastore .....")        
        GenServer.start_link(__MODULE__, :ok, [name: :Datastore])
    end

    def init(:ok) do
        clientsTbl = :ets.new(:clients, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        followingTbl = :ets.new(:following, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        tweetsTbl = :ets.new(:tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        clientTweets = :ets.new(:user_tweets, [:set, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        hashTweets =  :ets.new(:hashtag_tweets, [:bag, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        mentionTweets = :ets.new(:mention_tweets, [:bag, :protected, :named_table, 
            write_concurrency: true, read_concurrency: true])
        tables = %{"clientsTbl": clientsTbl, "tweetsTbl": tweetsTbl, "clientTweets": clientTweets,
            "hashTweets": hashTweets, "mentionTweets": mentionTweets, "followingTbl": followingTbl}
        {:ok, tables}
    end

    def handle_call({:register, user}, from, tables) do
        true = :ets.insert(:clients, {user, []})
        true = :ets.insert(:following, {user, []})
        true = :ets.insert(:user_tweets, {user, []})
        true = :ets.insert(:tweet_counter, {user, 0})
        true = :ets.insert(:retweet_counter, {user, 0})
        true = :ets.insert(:query_counter, {"queries", 0})
        true = :ets.insert(:query_counter, {"app_start", Time.utc_now()})
        {:reply, true, tables}
    end

    def handle_cast({:addTweet, user, tweet}, tables) do
        insert_into_tables(user, tweet)        
        {:noreply, tables}
    end

    def handle_call({:setFollowers, user, followers}, from, tables) do
        :ets.insert(:clients, {user, followers})
        set_following(user, followers)
        {:reply, :ok, tables}
    end

    def handle_call({:getFollowers, user}, from, tables) do
        # TODO get followers
        {u, followers} = hd(:ets.lookup(:clients, user))
        {:reply, followers, tables}
    end

    def handle_call({:getFollowing, user}, from, tables) do
        # TODO get followers
        {u, following} = hd(:ets.lookup(:following, user))
        {:reply, following, tables}
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

    defp set_following(user, followers) do
        Enum.each(followers, fn (x) ->
            {u, follow} = hd(:ets.lookup(:following, x))
            :ets.insert(:following,{u, [user|follow]})
        end)
    end
    
    defp insert_into_tables(user, tweet) do
        # clientTweets tbl        
        {_, tweets} = hd(:ets.lookup(:user_tweets, user))
        :ets.insert(:user_tweets, {user, [tweet|tweets]})

        # hashTweets tbl
        if (String.contains?tweet, "#") do
            hlist = ~r/#[^\s]+/ |> Regex.scan(tweet) |> Enum.map(&hd/1)
            Enum.each(hlist,fn x-> :ets.insert(:hashtag_tweets,{x,user,tweet}) end)
        end

        # mentionTweets tbl
        if(String.contains?tweet, "@") do
            alist = ~r/@[^\s]+/ |> Regex.scan(tweet) |> Enum.map(&hd/1)       
            Enum.each(alist,fn x-> :ets.insert(:mention_tweets,{x,user,tweet}) end)
            #Enum.each(alist, fn y-> :ets.insert(:user_tweets,{String.slice(y,1..-1),user,tweet})end)
        end       
    end
end