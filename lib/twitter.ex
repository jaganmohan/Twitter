defmodule Twitter do
  use Application
  @moduledoc """
  Documentation for Twitter.
  """

  def start(_type, _args) do
    IO.puts("Starting Twitter Application")
    node = Application.get_env(:twitter, :node_type)
    #if node == "server" do
    TwitterClone.Appserver.start_link(name: TwitterServer)
    #else if node =="simulator" do
    TwitterClient.Supervisor.start_link(name: TwitterSimulator)
  end

end
