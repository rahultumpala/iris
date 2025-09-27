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

    compile_path = normalize_source_beam(config)
    config = config |> Iris.ExDoc.Config.build(config[:version] || "dev", [])
    config = %Iris.ExDoc.Config{config | source_beam: compile_path}

    core_entity = Core.build(config)
    {:ok, json} = Jason.encode(core_entity, [{:escape, :unicode_safe}, {:pretty, true}])

    content = "const getGlobalEntity = () => { return #{json}; }"

    path = "iris/entity.js"
    IO.puts("Writing to #{path}")
    File.write!(path, content)
  end

  defp normalize_source_beam(config) do
    compile_path =
      if Mix.Project.umbrella?(config) do
        umbrella_compile_paths()
      else
        Mix.Project.compile_path()
      end

    compile_path
  end

  defp umbrella_compile_paths() do
    build = Mix.Project.build_path()

    for {app, _} <- Mix.Project.apps_paths() do
      Path.join([build, "lib", Atom.to_string(app), "ebin"])
    end
  end
end
