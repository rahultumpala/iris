defmodule Mix.Tasks.Iris do
  use Mix.Task
  alias Iris.Core

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

    IO.puts("\nYay! I have a working Mix Task")
    IO.inspect({"Project Config", config})

    core_entity = Core.build()
    {:ok, json} = Jason.encode(core_entity, [{:escape, :unicode_safe}, {:pretty, true}])

    File.write!("entity.json", json)
  end
end
