# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :twitterweb, TwitterwebWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QkGczfAeLgX9BVMUjLrqNXISoPIsQLuoFQKn3Qr9dxwyioJ8nzGa6hgkytC9i0q2",
  render_errors: [view: TwitterwebWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Twitterweb.PubSub,
           adapter: Phoenix.PubSub.PG2],
  num_clients: 10  # Change the number of clients as per requirement
                  # It should be same as simulator's numClients

# Configures Elixir's Logger
config :logger, :console,
  #compile_time_purge_level: :info,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
