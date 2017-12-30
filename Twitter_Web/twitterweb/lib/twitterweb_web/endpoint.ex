defmodule TwitterwebWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :twitterweb

  socket "/socket", TwitterwebWeb.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :twitterweb, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_twitterweb_key",
    signing_salt: "F+ucJ8d5"

  plug TwitterwebWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      numClients = config[:num_clients]#1000#Application.get_env(TwitterwebWeb.Endpoint, :num_clients)
      # create N client actors
      # get N from application config
      dist = zipf(numClients)
      #IO.puts("zipf distribution: #{inspect(dist)}")

      for i <- 1..numClients do
        client_name = "user#{i}"
        # register client process
        GenServer.call(:Datastore, {:register, client_name})
      end

      #creating total num of followers
      v = 0.9*numClients |> round
      v = Enum.random(v..numClients)
      total_followers = v/dist[1] |> round
      IO.puts("Total number of followers: #{total_followers}")
      IO.puts("Sum of zipf probabilities: #{Enum.reduce(dist, 0, fn({k, v}, acc) -> v + acc end)}")
      createFollowers(dist, numClients, total_followers)

      {:ok, config}
    end
    
  end

  def zipf(n, alpha \\ 1) do
    c = 1/Enum.reduce(1..n, 0, fn (x, acc) -> 
      acc = acc + 1/:math.pow(x,alpha) end)
    Enum.reduce(1..n, %{}, fn (x, acc) -> 
      acc = Map.put(acc, x, c/:math.pow(x,alpha)) end)
  end

  def createFollowers(dist, numClients, total_followers) do
    clients = Enum.map(1..numClients,fn x -> "user#{x}" end)
    for i <- 1..numClients do
      users = List.delete_at(clients, i-1)
      followers = Enum.take_random(users, dist[i]*total_followers|>round)
      GenServer.call(:Datastore, {:setFollowers, "user#{i}", followers})
    end
  end

end
