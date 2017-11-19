defmodule Twitter do
  use Application
  @moduledoc """
  Documentation for Twitter.
  """

  def start(_type, _args) do
    IO.puts("Starting Twitter Application")    
    TwitterClone.Appserver.start_link(name: TwitterServer)
    TwitterClient.Simulator.start_link(name: TwitterSimulator)
  end

end
