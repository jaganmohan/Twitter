defmodule Twitter do
  use Application
  @moduledoc """
  Documentation for Twitter.
  """

  def start(_type, _args) do
    IO.puts("Starting Twitter Application")    
    mode= Application.fetch_env!(:twitter, :mode)
    IO.puts mode
    case mode do
      #insert case to choose between TwitterServer or TwitterSimulator
      "server"->  TwitterClone.Appserver.start_link(name: TwitterServer)
      "simulator"-> TwitterClient.Supervisor.start_link(name: TwitterSimulator)
      _ -> IO.puts "Wrong mode."
    end
  end

end
