defmodule TwitterClient.Supervisor do
    use Supervisor

    def start_link(opts) do
        IO.puts("Starting Simulator .....")
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        children = [
            {TwitterClient.Client, name: Client},
        ]
        Supervisor.init(children, strategy: :simple_one_for_one)
    end
end