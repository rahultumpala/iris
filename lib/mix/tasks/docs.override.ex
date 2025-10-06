defmodule Mix.Tasks.Docs.Override do
  use Mix.Task

  @moduledoc ~S"""
  Overrides Mix.Tasks.Doc to include the screenshot in generated docs assets
  """

  @docs_dir "./doc"
  @img_file "screenshot.png"

  @doc false
  def run(args, _config \\ Mix.Project.config()) do
    Mix.Task.run("iris.docs", args)

    docs_dir = Path.expand(@docs_dir)

    if File.exists?(@docs_dir) do
      content = File.read!(Path.expand(@img_file))
      out_path = Path.join(docs_dir, @img_file)
      File.write!(out_path, content)
    end
  end
end
