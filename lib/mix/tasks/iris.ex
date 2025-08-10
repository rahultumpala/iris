defmodule Mix.Tasks.Iris do
  use Mix.Task
  alias Iris.Core

  @moduledoc ~S"""
  Generates an interactive web page from project sources.
  """
  @shortdoc "Generates iris view for the project"
  @requirements ["compile", "app.config"]

  @doc false
  def run(args, config \\ Mix.Project.config()) do
    {:ok, _} = Application.ensure_all_started(:iris)

    unless Code.ensure_loaded?(Iris.Config) do
      Mix.raise(
        "Could not load Iris configuration. Please make sure you are running the " <>
          "docs task in the same Mix environment it is listed in your deps"
      )
    end

    if args != [] do
      Mix.raise("Extraneous arguments on the command line")
    end

    IO.inspect({"Project Config", config})

    core_entity = Core.build(config)
    {:ok, json} = Jason.encode(core_entity, [{:escape, :unicode_safe}, {:pretty, true}])

    path = "assets/entity.json"
    IO.puts("Writing to #{path}")
    File.write!(path, json)
  end
end
