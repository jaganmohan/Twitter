defmodule SocketClient do
    @moduledoc false
    require Logger
    alias Phoenix.Channels.GenSocketClient
    @behaviour GenSocketClient
  
    def start_link({i,numClients}, sock_opts, genservr_opts) do
      GenSocketClient.start_link(
            __MODULE__,
            Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
            {"ws://localhost:4000/socket/websocket", i, numClients},
            sock_opts, genservr_opts
          )
    end
  
    def init({url, i, numClients}) do
      {:connect, url, [], %{first_join: true, ping_ref: 1, id: i, 
        numClients: numClients}}
    end
  
    def handle_connected(transport, state) do
      Logger.info("connected")
      GenSocketClient.join(transport, "tweet:user#{state.id}")
      GenSocketClient.join(transport, "query:user#{state.id}")
      {:ok, state}
    end
  
    def handle_disconnected(reason, state) do
      Logger.error("Logged out: #{inspect reason}")
      Process.send_after(self(), :connect, :timer.seconds(1))
      {:ok, state}
    end
  
    def handle_joined(topic, _payload, transport, state) do
  
      if state.first_join do
        Logger.info(" user#{state.id} logging in ")
        :timer.send_interval(:timer.seconds(1), self(), :tweet_msg)
        :timer.send_interval(:timer.seconds(2), self(), :query_tweet)
        :timer.send_interval(:timer.seconds(10), self(), :show_tweet)
        {:ok, %{state | first_join: false, ping_ref: 1}}
      else
        {:ok, %{state | ping_ref: 1}}
      end
    end
  
    def handle_join_error(topic, payload, _transport, state) do
      Logger.error("join error on the topic #{topic}: #{inspect payload}")
      {:ok, state}
    end
  
    def handle_channel_closed(topic, payload, _transport, state) do
      Logger.error("disconnected from the topic #{topic}: #{inspect payload}")
      Process.send_after(self(), {:join, topic}, :timer.seconds(1))
      {:ok, state}
    end
  
    def handle_message(topic, event, payload, _transport, state) do
      Logger.info("message on topic #{topic}: #{event} #{inspect payload}")

      case event do
        "new_tweet" ->
          # code for re-tweet
          l1 = [0,0,0,1,0,0,0,1,0,0]
          l2 = [1,0,0,0,1,0,0,0,0,1]
          l1 = Enum.random(l1)
          l2 = Enum.random(l2)
          if l1 == l2 and l1 == 1 do
            send(self(), :retweet_msg)
          end
        _ -> nil
      end

      {:ok, state}
    end
  
    def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
      Logger.info("server pong ##{payload["response"]["ping_ref"]}")
      {:ok, state}
    end

    def handle_reply(topic, _ref, payload, _transport, state) do
      Logger.warn("reply on topic #{topic}: #{inspect payload}")
      {:ok, state}
    end
  
    def handle_info(:connect, _transport, state) do
      Logger.info("Logging In")
      {:connect, state}
    end

    def handle_info({:join, topic}, transport, state) do
      Logger.info("joining the topic #{topic}")
      case GenSocketClient.join(transport, topic) do
        {:error, reason} ->
          Logger.error("error joining the topic #{topic}: #{inspect reason}")
          Process.send_after(self(), {:join, topic}, :timer.seconds(1))
        {:ok, _ref} -> :ok
      end
  
      {:ok, state}
    end

    def handle_info(:ping_server, transport, state) do
      Logger.info("sending ping ##{state.ping_ref}")
      GenSocketClient.push(transport, "ping", "ping", %{ping_ref: state.ping_ref})
      {:ok, %{state | ping_ref: state.ping_ref + 1}}
    end

    ## client functionalites ##
    def handle_info(:tweet_msg, transport, state) do
      tweet = createTweet(state.numClients)
      GenSocketClient.push(transport, "tweet:user#{state.id}", "tweet_msg", 
        %{uid: "user#{state.id}", body: tweet})
      {:ok, state}
    end

    def handle_info(:retweet_msg, transport, state) do
      tweet = createTweet(state.numClients)
      GenSocketClient.push(transport, "tweet:user#{state.id}", "retweet_msg", 
        %{uid: "user#{state.id}", body: " RE-TWEET : "<>tweet})
      {:ok, state}
    end

    def handle_info(:query_tweet, transport, state) do
      i=Enum.random([1,2])    
      case(i) do
        1-> hashtags=["#husky","#boo","#elixi","#final","#pizza","#UF","#GoGators","#Nirvana","#GunnRoses","#Happy"]
            sizeh=Enum.count(hashtags)
            index=:rand.uniform(sizeh)-1
            query=Enum.at(hashtags,index)
            GenSocketClient.push(transport,"query:user#{state.id}","hashtag",%{uid: "user#{state.id}", query_body: query} )

        2-> query="@user"<>Integer.to_string(:rand.uniform(state.numClients))
            GenSocketClient.push(transport,"query:user#{state.id}","mention",%{uid: "user#{state.id}", query_body: query} )
      end
      {:ok, state}
    end

    def handle_info(:show_tweet, transport, state) do
          GenSocketClient.push(transport,"query:user#{state.id}","show_tweet",%{uid: "user#{state.id}"})  
       {:ok, state}
     end    

    def handle_info(message, _transport, state) do
      Logger.warn("Unhandled message #{inspect message}")
      {:ok, state}
    end

    def createTweet(numClient) do
      tweets=["booyaaaaaaaaa.", "Merry christmas", "Where do you wanno go?" ,"Scooby Dooby doo.","Imma so hungry.","How you doing?","Welcome to the jungle.","Take me home to the paradise city."]
      hashtags=["#husky","#boo","#elixi","#final","#pizza","#UF","#GoGators","#Nirvana","#GunnRoses","#Happy"]
      sizet=Enum.count(tweets)
      sizeh=Enum.count(hashtags)
       index1=:rand.uniform(sizet)-1
       index2=:rand.uniform(sizeh)-1
      #   IO.puts"#{index1}..#{index2}.."
      mentions="@user"<>Integer.to_string(:rand.uniform(numClient))
      tweet=Enum.at(tweets,index1)<>" "<>Enum.at(hashtags,index2)<>" "<>mentions
      # IO.puts "#{tweet}"
      tweet
  end
end  