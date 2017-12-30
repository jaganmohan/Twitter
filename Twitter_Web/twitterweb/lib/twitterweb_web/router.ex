defmodule TwitterwebWeb.Router do
  use TwitterwebWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TwitterwebWeb do
    pipe_through :api

    post "/auth/register", AuthHandler, :register
    post "/auth/login", AuthHandler, :login
    get "/auth/logout/:user", AuthHandler, :logout

    post "/tweet", TweetHandler, :tweet
    post "/retweet", TweetHandler, :retweet
    post "/subscribe", TweetHandler, :subscribe
    post "/setfollowers", TweetHandler, :setFollowers

    get "/query/all", QueryHandler, :queryTweets
    get "/query/tags", QueryHandler, :queryTags
    get "/query/user", QueryHandler, :queryMentions

  end

end
