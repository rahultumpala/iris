defmodule Iris do
  alias Iris.Core

  defmacrop list_static() do
    "iris/*"
    |> Path.wildcard()
    |> Enum.map(fn path ->
      Module.put_attribute(__CALLER__.module, :external_resource, path)
      {path, File.read!(path)}
    end)
  end

  def build(config) do
    core_entity = Core.build(config)
    {:ok, json} = Jason.encode(core_entity, [{:escape, :unicode_safe}, {:pretty, true}])

    entity_content = "const getGlobalEntity = () => { return #{json}; }"
    entity_path = "iris/entity.js"
    entity_asset = {entity_path, entity_content}

    Mix.shell().info("Writing to iris/")

    [entity_asset | list_static()]
    |> Enum.each(fn {path, content} ->
      Mix.shell().info("Writing #{path}")
      File.write!(path, content)
    end)

    Mix.shell().info("Iris view available at iris/index.html")
  end
end
