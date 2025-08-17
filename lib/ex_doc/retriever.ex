defmodule Iris.ExDoc.Retriever do
  # Functions to extract documentation information from modules.
  @moduledoc false

  defmodule Error do
    @moduledoc false
    defexception [:message]
  end

  alias Iris.ExDoc.GroupMatcher
  alias Iris.ExDoc.Retriever.Error

  def get_module(module, config) do
    with {:docs_v1, _, language, _, _, _metadata, _} = docs_chunk <- docs_chunk(module),
         {:ok, language} <- ExDoc.Language.get(language, module),
         %{} = module_data <- language.module_data(module, docs_chunk, config) do
      {:ok, generate_node(module, module_data, config)}
    else
      _ ->
        {:error, module}
    end
  end

  defp docs_chunk(module) do
    result = Code.fetch_docs(module)
    # Refs.insert_from_chunk(module, result)

    case result do
      {:docs_v1, _, _, _, :hidden, _, _} ->
        false

      {:docs_v1, _, _, _, _, _, _} = docs ->
        case Code.ensure_loaded(module) do
          {:module, _} ->
            docs

          {:error, reason} ->
            ExDoc.Utils.warn("skipping docs for module #{inspect(module)}, reason: #{reason}", [])
            false
        end

      {:error, :chunk_not_found} ->
        false

      {:error, :module_not_found} ->
        unless Code.ensure_loaded?(module) do
          raise Error, "module #{inspect(module)} is not defined/available"
        end

      {:error, _} = error ->
        raise Error, "error accessing #{inspect(module)}: #{inspect(error)}"

      _unknownFmt ->
        raise Error,
              "unknown format in Docs chunk. This likely means you are running on " <>
                "a more recent Elixir version that is not supported by ExDoc. Please update."
    end
  end

  defp generate_node(module, module_data, config) do
    source = %{
      url_pattern: config.source_url_pattern,
      path: module_data.source_file,
      relative_path: path_relative_to_cwd(module_data.source_file)
    }

    {doc_line, doc_file, format, source_doc, nil, metadata} = get_module_docs(module_data, source)

    group_for_doc = config.group_for_doc
    annotations_for_docs = config.annotations_for_docs

    docs = get_docs(module_data, source, group_for_doc, annotations_for_docs)
    metadata = Map.put(metadata, :kind, module_data.type)
    group = GroupMatcher.match_module(config.groups_for_modules, module, module_data.id, metadata)
    {nested_title, nested_context} = module_data.nesting_info || {nil, nil}

    %Iris.ExDoc.ModuleNode{
      id: module_data.id,
      title: module_data.title,
      nested_title: nested_title,
      nested_context: nested_context,
      group: group,
      module: module,
      type: module_data.type,
      deprecated: metadata[:deprecated],
      docs_groups: config.docs_groups ++ module_data.default_groups,
      docs: ExDoc.Utils.natural_sort_by(docs, &"#{&1.name}/#{&1.arity}"),
      doc_format: format,
      doc: nil,
      source_doc: source_doc,
      moduledoc_line: doc_line,
      moduledoc_file: doc_file,
      source_url: source_link(source, module_data.source_line),
      language: module_data.language,
      annotations: List.wrap(metadata[:tags]),
      metadata: metadata
    }
  end

  # Helpers

  defp get_module_docs(module_data, source) do
    {:docs_v1, anno, _, format, moduledoc, metadata, _} = module_data.docs
    doc_file = anno_file(anno, source)
    doc_line = anno_line(anno)
    _options = [file: doc_file, line: doc_line + 1]
    {doc_line, doc_file, format, moduledoc, nil, metadata}
  end

  defp get_docs(module_data, source, group_for_doc, annotations_for_docs) do
    {:docs_v1, _, _, _, _, _, docs} = module_data.docs

    nodes =
      for doc <- docs,
          doc_data = module_data.language.doc_data(doc, module_data) do
        get_doc(doc, doc_data, module_data, source, group_for_doc, annotations_for_docs)
      end

    filter_defaults(nodes)
  end

  defp get_doc(doc, doc_data, module_data, source, group_for_doc, annotations_for_docs) do
    {:docs_v1, _, _, _content_type, _, module_metadata, _} = module_data.docs
    {{type, name, arity}, anno, _signature, source_doc, metadata} = doc
    doc_file = anno_file(anno, source)
    doc_line = anno_line(anno)

    metadata =
      Map.merge(
        %{kind: type, name: name, arity: arity, module: module_data.module},
        metadata
      )

    source_url = source_link(doc_data.source_file, source, doc_data.source_line)

    annotations =
      annotations_for_docs.(metadata) ++
        annotations_from_metadata(metadata, module_metadata) ++ doc_data.extra_annotations

    defaults = get_defaults(name, arity, Map.get(metadata, :defaults, 0))

    group = group_for_doc.(metadata) || doc_data.default_group

    %Iris.ExDoc.DocNode{
      id: doc_data.id_key <> nil_or_name(name, arity),
      name: name,
      arity: arity,
      deprecated: metadata[:deprecated],
      doc: nil,
      source_doc: source_doc,
      doc_line: doc_line,
      doc_file: doc_file,
      defaults: ExDoc.Utils.natural_sort_by(defaults, fn {name, arity} -> "#{name}/#{arity}" end),
      signature: signature(doc_data.signature),
      specs: doc_data.specs,
      source_url: source_url,
      type: doc_data.type,
      group: group,
      annotations: annotations
    }
  end

  defp get_defaults(_name, _arity, 0), do: []

  defp get_defaults(name, arity, defaults) do
    for default <- (arity - defaults)..(arity - 1), do: {name, default}
  end

  defp filter_defaults(nodes) do
    Enum.map(nodes, &filter_defaults(&1, nodes))
  end

  defp filter_defaults(node, nodes) do
    update_in(node.defaults, fn defaults ->
      Enum.reject(defaults, fn {name, arity} ->
        Enum.any?(nodes, &match?(%{name: ^name, arity: ^arity}, &1))
      end)
    end)
  end

  ## General helpers

  defp nil_or_name(name, arity) do
    if name == nil do
      "nil/#{arity}"
    else
      "#{name}/#{arity}"
    end
  end

  defp signature(list) when is_list(list), do: Enum.join(list, " ")

  defp annotations_from_metadata(metadata, module_metadata) do
    # Give precedence to the function/callback/type metadata over the module metadata.
    cond do
      since = metadata[:since] -> ["since #{since}"]
      since = module_metadata[:since] -> ["since #{since}"]
      true -> []
    end
  end

  defp anno_line(line) when is_integer(line), do: abs(line)
  defp anno_line(anno), do: anno |> :erl_anno.line() |> abs()

  defp anno_file(anno, source) do
    case :erl_anno.file(anno) do
      :undefined ->
        source.relative_path

      file ->
        source.path
        |> Path.dirname()
        |> Path.join(file)
        |> path_relative_to_cwd()
    end
  end

  # TODO: Remove when we require Elixir 1.16
  if function_exported?(Path, :relative_to_cwd, 2) do
    defp path_relative_to_cwd(path), do: Path.relative_to_cwd(path, force: true)
  else
    defp path_relative_to_cwd(path), do: Path.relative_to_cwd(path)
  end

  defp source_link(nil, source, line), do: source_link(source, line)

  defp source_link(file, %{url_pattern: url_pattern}, line) do
    url_pattern.(path_relative_to_cwd(file), line)
  end

  defp source_link(%{url_pattern: url_pattern, relative_path: path}, line) do
    url_pattern.(path, line)
  end
end
