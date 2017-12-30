defmodule Twitterweb.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    tweet_counter = :ets.new(:tweet_counter, [:set, :public, :named_table, 
    write_concurrency: true, read_concurrency: true])
    retweet_counter = :ets.new(:retweet_counter, [:set, :public, :named_table, 
    write_concurrency: true, read_concurrency: true])
    query_counter = :ets.new(:query_counter, [:set, :public, :named_table, 
    write_concurrency: true, read_concurrency: true])

    # Define workers and child supervisors to be supervised
    children = [
      # Start your own worker by calling: Twitterweb.Worker.start_link(arg1, arg2, arg3)
      worker(Twitterweb.Datastore, []),
      # Start the endpoint when the application starts
      supervisor(TwitterwebWeb.Endpoint, []),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Twitterweb.Supervisor]
    Supervisor.start_link(children, opts)

  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwitterwebWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def stop(state) do
    {_, app_start} = hd(:ets.lookup(:query_counter, "app_start"))
    time_sec = Time.diff(Time.utc_now(), app_start)
    total_tweets = Enum.reduce(:ets.tab2list(:tweet_counter), 0, fn(x, acc) ->
      {_, tweets} = x
      acc + tweets
    end)
    tweets_sec = total_tweets/time_sec
    total_retweets = Enum.reduce(:ets.tab2list(:retweet_counter), 0, fn(x, acc) ->
      {_, tweets} = x
      acc + tweets
    end)
    retweets_sec = total_retweets/time_sec
    {_, total_queries} = hd(:ets.lookup(:query_counter, "queries"))
    query_sec = total_queries/time_sec

    IO.puts("-------------------------- Metrics -------------------------------")
    IO.puts("Total time in seconds: #{time_sec}")
    IO.puts("Total tweets: #{total_tweets}")
    IO.puts("Total retweets: #{total_retweets}")
    IO.puts("Total queries: #{total_queries}")
    IO.puts("Total tweets per sec: #{tweets_sec}")
    IO.puts("Total retweets per sec: #{retweets_sec}")
    IO.puts("Total queries per sec: #{query_sec}")
    IO.puts("------------------------------------------------------------------")
    
  end

end
