# Twitter

**TODO: Add description**

## Compile application
To run the application go to the home directory "twitter" and run the following command
- mix compile

## Start Application
To run the application, run the following command in home directory
- iex -S mix

## Stop Application
To stop the application, run the following commands
- Application.stop(:twitter)
- Application.stop(:logger)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `twitter` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:twitter, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/twitter](https://hexdocs.pm/twitter).

