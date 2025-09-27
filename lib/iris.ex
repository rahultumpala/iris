defmodule Iris do
  alias Iris.Core

  def build(config) do
    core_entity = Core.build(config)
    {:ok, json} = Jason.encode(core_entity, [{:escape, :unicode_safe}, {:pretty, true}])
    entity_content = "const getGlobalEntity = () => { return #{json}; }"

    cwd_iris_path = "iris" |> Path.relative_to_cwd()
    File.mkdir_p!(cwd_iris_path)
    File.cp_r!("iris/", cwd_iris_path)

    Mix.shell().info("Writing to iris/")
    path = "iris/entity.js"
    File.write!(path, entity_content)

    copy_html()
  end

  defp copy_html do
    "iris"
    |> Path.relative_to_cwd()
    |> File.ls()
    |> IO.inspect()
  end
end
