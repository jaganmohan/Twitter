defmodule TwitterwebWeb.QueryChannel do
    use Phoenix.Channel

    def join("query:user"<>id, _auth_message, socket) do
        IO.puts "user#{id} logged in"
        {:ok, socket}
    end

    def handle_in("hashtag", %{"uid" => uid, "query_body" => query}, socket) do
      {_, query_count} = hd(:ets.lookup(:query_counter, "queries"))
      :ets.insert(:query_counter, {"queries", query_count+1})
        IO.puts("---------------#{uid}: #{query}-----------------")
        results=:ets.lookup(:hashtag_tweets, query)
        query_results=[]
        # IO.puts("==============Results===== #{inspect(results)} ======================")
       query_results = Enum.reduce(results, [], fn (x, acc) ->
                                item=elem(x,0)<>" "<>elem(x,1)<>" "<>elem(x,2)
                                [item|acc]                                                                
                            end)
        # IO.puts "============Hashtag-Query Results======#{inspect query_results}==============="

       
        broadcast! socket, "Hashtag-Query Results", %{uid: uid, results: query_results}
        {:noreply, socket}
    end
    
    def handle_in("mention", %{"uid" => uid, "query_body" => query}, socket) do
      {_, query_count} = hd(:ets.lookup(:query_counter, "queries"))
      :ets.insert(:query_counter, {"queries", query_count+1})
        IO.puts("------Mention---------#{uid} #{query}-----------------")
        results=:ets.lookup(:mention_tweets, query)
        query_results=[]
        query_results = Enum.reduce(results, [], fn (x, acc) ->
                                item=elem(x,0)<>" "<>elem(x,1)<>" "<>elem(x,2)
                                [item|acc]                                                                
                            end)
       # IO.puts "============Mention-Query Results======#{inspect query_results}==============="

        broadcast! socket, "Mention-Query Results", %{uid: uid, results: query_results}
        {:noreply, socket}
    end

    def handle_in("show_tweet",%{"uid" => uid}, socket) do
        
                  results=:ets.lookup(:user_tweets,uid)             #personal tweets from user's table               

                  personal_tweets=elem(Enum.at(results,0),1)
                  personal_tweets =
                  if(Enum.count(results) > 20) do
                    personal_tweets= Enum.take(results,20) 
                  else
                    {_, personal_tweets}=hd(:ets.lookup(:user_tweets,uid))
                    personal_tweets
                  end

                  {_, followee_list} = hd(:ets.lookup(:following,uid))                 #Look up the tweets of your followers
                  sublist = Enum.reduce(followee_list, [], fn (followee, acc) ->
                    {_, tweets} = hd(:ets.lookup(:user_tweets,followee))
                    [tweets|acc]
                  end)   
                 recieved_list = List.flatten(sublist) |> Enum.shuffle

                 recieved_list =
                 if(Enum.count(recieved_list) > 20) do
                    Enum.take(recieved_list,20) 
                 else
                    recieved_list
                 end
 
                broadcast! socket, "View Timeline", %{uid: uid, personal: personal_tweets,
                                             received_results: recieved_list}
                {:noreply, socket}
            end

    alias Phoenix.Socket.Broadcast
    def handle_info(%Broadcast{topic: _, event: ev, payload: payload}, socket) do
      push socket, ev, payload
      {:noreply, socket}
    end

end