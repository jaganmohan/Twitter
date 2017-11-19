defmodule TwitterClient.Supervisor do
    use Supervisor

    def start_link(opts) do
        IO.puts("Starting Simulator .....")
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    def init(:ok) do
        children = [
            {TwitterClient.Simulator, name: Simulator},
        ]
        Supervisor.init(children, strategy: :one_for_one)
    end
end