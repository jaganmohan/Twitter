defmodule TwitterClient.Client do
    use GenServer

    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts, name: client_name)
    end

    def init(opts) do
        IO.puts("Initializing Client .....")
        #TODO define state
        {:ok, %{}}
    end

    def handle_cast({:dist, tweet},state) do
        # TODO log msg: user tweet when user is live

        #Re-tweet optional
        #publishTweet(tweet)
    end

    def publishTweet(tweet) do
        # publish when user is logged in
        # TODO construct tweet randomly and call this method from elsewhere
        tweet = 
        if tweet == nil do
            %Util.Tweet{}
        end
        GenServer.cast(Server, {:publish, tweet})
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