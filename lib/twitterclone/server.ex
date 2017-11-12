defmodule TwitterClone.Server do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def init(opts) do
        #TODO state
    end

    def handle_cast({:publish, tweet}, state) do
        distTweets(tweet)
        {:noreply, state}
    end

    def tweet(twt) do
        GenServer.cast(Server, {:publish, twt})
    end

    def getTweets(query) do
        query = %{query | results:
        case query.type do
            :all ->
                # query all tweets from followers from datastore
                GenServer.cast(Datastore, {:getAllTweets, query.origin})
            :hashtags ->
                # query all tags with that particular hashtag
                GenServer.cast(Datastore, {:getHashTagTweets, query.origin})
            :mentions ->
                # query all tweets with list of mentions from datastore
                GenServer.cast(Datastore, {:getMentionsTweets, query.origin})
            _ -> []
        end
        }
        query
    end

    def distTweets(tweet) do
        # Get list of subscribers for the origin
        followers = DataStore.getFollowers(tweet.origin)
        for follower <- followers do
            # TODO check if user is live/logged in
            GenServer.cast(follower, {:dist, tweet})
            # TODO also store the tweets for that user
        end
    end

end