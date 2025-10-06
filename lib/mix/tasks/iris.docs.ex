defmodule Mix.Tasks.Iris.Docs do
  use Mix.Task

  @requirements ["iris"]

  @moduledoc ~S"""
  Runs on top of ExDocs' Mix.Tasks.Doc to include the generated Iris GUI

  Requires IrisGUI.md to be present in the projects root directory and added to docs method in mix.exs as such

      defp docs do
        [
          extras:
            [
              "iris-view.md"
            ],
        ]
      end

  The generated iris UI can be found by clicking on the iris-view link in the pages section of generated docs.
  """

  @docs_dir "./doc"
  @iris_dir "./iris"
  @index_html "index.html"
  @iris_html "irisgui.html"

  @doc false
  def run(args, config \\ Mix.Project.config()) do
    Kernel.apply(Mix.Tasks.Docs, :run, [args, config])

    if File.exists?(@docs_dir) do
      files = @iris_dir |> Path.expand() |> File.ls!() |> Enum.filter(&is_not_index/1)

      Enum.each(files, fn file ->
        Path.join(@iris_dir, file) |> File.copy!(Path.join(@docs_dir, file))
      end)

      File.copy!(Path.join(@iris_dir, @index_html), Path.join(@docs_dir, @iris_html))
    end
  end

  defp is_not_index(name) do
    !String.equivalent?(name, @index_html)
  end
end
