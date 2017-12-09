defmodule TwitterClone.Server do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        IO.puts("Initializing Server .....")
        IO.inspect(self())
        :global.register_name(:Server, self())
        :global.sync()
        #TODO state
        {:ok, %{}}
    end

    def handle_call({:register, user}, from, state) do
        IO.puts("Registering user: #{inspect(user)}")
        true = GenServer.call(:Datastore, {:register, user})
        {:reply, true, state}
    end

    def handle_call({:setFollowers, user, followers}, from, state) do
        GenServer.cast(:Datastore, {:setFollowers, user, followers})
        {:reply, :ok, state}
    end

    def handle_cast({:publish, tweet}, state) do
        IO.puts("Tweet from #{tweet.origin}: #{tweet.msg}")
        GenServer.call(:Datastore, {:addTweet, tweet.origin, tweet})
        distTweets(tweet)
        {:noreply, state}
    end

    def getTweets(query) do
        query = %{query | results:
        case query.type do
            :all ->
                # query all tweets from followers from datastore
                GenServer.call(Datastore, {:getAllTweets, query.origin})
            :hashtags ->
                # query all tags with that particular hashtag
                GenServer.call(Datastore, {:getHashTagTweets, query.origin})
            :mentions ->
                # query all tweets with list of mentions from datastore
                GenServer.call(Datastore, {:getMentionsTweets, query.origin})
            _ -> []
        end
        }
        query
    end

    def distTweets(tweet) do
        # Get list of subscribers for the origin
        followers = GenServer.call(:Datastore, {:getFollowers,tweet.origin})
        for follower <- followers do
            # TODO check if user is live/logged in
            followerName = follower
            GenServer.call(:Datastore, {:addTweet, follower, tweet})
            follower = :global.whereis_name(String.to_atom(follower))
            GenServer.cast(follower, {:dist, followerName, tweet})
            # TODO also store the tweets for that user
        end
    end

end