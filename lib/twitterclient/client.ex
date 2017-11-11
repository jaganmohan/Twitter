defmodule TwitterClient.Client do
    use GenServer

    def init() do
        #TODO define state
    end

    def handle_cast({:dist, tweet},state) do
        # TODO log msg: user tweet when user is live

        #Re-tweet optional
        #publishTweet(tweet)
    end

    def publishTweet(tweet) do
        # publish when user is logged in
        # TODO construct tweet randomly and call this method from elsewhere
        if tweet == nil do
            tweet = %Util.Tweet{}
        end
        GenServer.cast(server, {:publish, tweet})
    end

    def queryTweets(query) do
        # construct query if query is nil
        if query == nil do
            query = %Util.Query{}
        end
        GenServer.call(server, {:query, query})
    end
end