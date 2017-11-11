defmodule TwitterClone.Server do
    use GenServer

    def init() do
        #TODO state
    end

    def handle_cast({:publish, tweet}, state) do
        distTweets(tweet)
        {:noreply, state}
    end

    def handle_call({:query, query}, from, state) do
        query.results = 
        case query.type do
            :all ->
                # query all tweets from followers from datastore
            :hashtags ->
                # query all tags with that particular hashtag
            :mentions ->
                # query all tweets with list of mentions from datastore
            _ -> []
        end
        {:reply, query, state}
    end

    def distTweets(tweet) do
        # Get list of subscribers for the origin
        for follower <- followers do
            # TODO check if user is live/logged in
            GenServer.cast(follower, {:dist, tweet})
            # TODO also store the tweets for that user
        end
    end

end