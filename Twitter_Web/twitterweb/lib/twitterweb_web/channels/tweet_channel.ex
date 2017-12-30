defmodule TwitterwebWeb.TweetChannel do
    use Phoenix.Channel

    def join("tweet:user"<>id, _auth_message, socket) do
        #:ok = TwitterwebWeb.Endpoint.subscribe("query:user"<>id)
        {:ok, socket
                |> assign(:topics, [])
                |> subscribe_to_users("user#{id}")}
    end

    #def join("")

    def handle_in("tweet_msg", %{"uid" => uid, "body" => body}, socket) do
        {_, tweet_count} = hd(:ets.lookup(:tweet_counter, uid))
        :ets.insert(:tweet_counter, {uid, tweet_count+1})
        # insert new tweets into table
        GenServer.cast(:Datastore, {:addTweet, uid, body})
        # broadcast new tweet
        broadcast! socket, "new_tweet", %{uid: uid, body: body}
        {:noreply, socket}
    end

    def handle_in("retweet_msg", %{"uid" => uid, "body" => body}, socket) do
       {_, tweet_count} = hd(:ets.lookup(:retweet_counter, uid))
       :ets.insert(:retweet_counter, {uid, tweet_count+1})
        # broadcast new tweet
        broadcast! socket, "new_tweet", %{uid: uid, body: body}
        {:noreply, socket}
    end

    alias Phoenix.Socket.Broadcast
    def handle_info(%Broadcast{topic: _, event: ev, payload: payload}, socket) do
      push socket, ev, payload
      {:noreply, socket}
    end

    defp subscribe_to_users(socket, user) do
        # get followers from database and subscribe to all those channels
        following = GenServer.call(:Datastore, {:getFollowing, user})
        Enum.reduce(following, socket, fn(x,acc) ->
            topics = acc.assigns.topics
            topic = "tweet:#{x}"
            if topic in topics do
                acc
            else
                :ok = TwitterwebWeb.Endpoint.subscribe(topic)
                assign(acc, :topics, [topic|topics])
            end
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