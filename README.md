# Iris

A tool to visualize your elixir code base

The following features are implemented.

- List all Applications in elixir lib
- List all Modules in an application
- List all methods in an application
- Generate & View inbound and outbound calls from a selected method
- Click on outbound call method to expand the method and view its outbound calls
- Show Method documentation
- Detect and denote recursive methods with a recursion icon
- Detect and denote methods that have documentation with a docs icon

The following features are yet to be implemented.

- Support for umbrella projects
- Show Module documentation
- Search feature to search methods

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `iris` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:iris, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/iris>.