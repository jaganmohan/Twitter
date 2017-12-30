The library phoenix_gen_socket_client implements an Elixir client for Phoenix Channels protocol 2.x.  
Twitterweb is the phoenix engine using websockets.
Simulator is the simulator simulating client behavior. 

HOW TO RUN 
Imp: Start twitterweb(engine) before running simulator

-twitterweb 
mix compile 
iex -S mix phx.server 
-Change the value of numClients in config.exs of twitterweb application according to the requirement for testing. This value has been set to 10 for now. But as long as this value is greater than the <numclients> parameter value to project4 the implementation will work correctly.  
-If upon running you receive error of not having installed required dependencies then run: 
 mix deps.get 
-If you want to run on separate machines then change the URL in start_link() of socket_client.ex of simulator.

- simulator 
mix escript.build 
escript project <numclients> 
 
HOW TO STOP 
Imp: stop simulator first then twitterweb to properly see the metrics 

- simulator 
 Ctrl+c twice 
 
- twitterweb 
 In iex interactive session itself 
 Appplicatio.stop(:twitterweb) 
  
 
 
DESCRIPTION 
• Register account • Send tweet. Tweets can have hashtags and mentions  • Subscribe to user's tweets • Re-tweets (so that your subscribers get an interesting tweet you got by other means) • Allow querying tweets subscribed to, tweets with specific hashtags, tweets in which the user is mentioned (my mentions) • Simulate a Zipf distribution on the number of subscribers. For accounts with a lot of subscribers, increase the number of tweets. Make some of these messages re-tweets 
MODULES IN THE PROJECT 
project4 
socket_client: Creates the socket connections for the required number of clients. Each client upon registration is associated with a topic. The client will then subscribe to the the topics of its followers, query.  The API calls to the server to handle all the functionalities are initiated here. 
simulator: Starts the required number of clients.  
Twitterweb 
 This is the engine of our twitter clone. 
endpoint.ex: Generates the Zipf distribution  based on the number of followers each client has. 
Channels: 
 These channels implement the callbacks for the various functionalities of this project.  
-Tweet:* to handle all tweet related topics (TweetChannel) 
-Query:* to handle all query related topics (QueryChannel) 
Datastore: Holds the ETS tables. Basically, acts as the database on the server. 
