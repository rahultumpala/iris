defimpl Jason.Encoder, for: [Iris.Entity] do
  def encode(struct, opts) do
    Jason.Encoder.Map.encode(
      %{
        "applications" => struct.applications
      },
      opts
    )
  end
end

defimpl Jason.Encoder, for: [Iris.Entity.Application] do
  def encode(struct, opts) do
    Jason.Encoder.Map.encode(
      %{
        "application" => struct.application,
        "modules" => struct.modules
      },
      opts
    )
  end
end

defimpl Jason.Encoder, for: [Iris.Entity.Module] do
  def encode(struct, opts) do
    Jason.Encode.map(
      %{
        "module" => struct.module,
        "application" => struct.application,
        "ex_doc" => struct.ex_doc,
        "methods" => struct.methods,
        "in_calls" => struct.in_calls,
        "out_calls" => struct.out_calls
      },
      opts
    )
  end
end

defimpl Jason.Encoder, for: [Iris.Entity.Module.Method] do
  require Protocol

  def encode(struct, opts) do
    Jason.Encode.map(
      %{
        "name" => struct.name,
        "arity" => struct.arity,
        "module" => struct.module,
        # "compiled_code" => struct.compiled_code,
        "type" => struct.type,
        "ex_doc" => struct.ex_doc,
        "view" => struct.view,
        "is_export" => struct.is_export,
        "is_recursive" => struct.is_recursive,
        "html_type_text" => struct.html_type_text,
        "call_instructions" => struct.call_instructions,
        "tooltip_text" => get_tooltip_text(struct.html_type_text)
      },
      opts
    )
  end

  def encode_tuple(data, opts) when is_tuple(data) do
    data
    |> Tuple.to_list()
    |> List.flatten()
    |> Jason.Encoder.List.encode(opts)
  end

  defp get_tooltip_text(html_type) do
    case html_type do
      "INT" -> "Private Method"
      "EXP" -> "Exported Method"
      "AGF" -> "Auto Generated Function"
      "BIF" -> "Built-In Function"
      "IMP" -> "Imported Method"
      _ -> ""
    end
  end
end

defimpl String.Chars, for: [Iris.Entity.Module.Method] do
  def to_string(struct) do
    # This is used while generating the Key in KV pairs in in_calls & out_calls
    # Will need to modify to prefix Application name too.
    # output in MFA style to avoid ambiguity
    struct.module <> "." <> struct.name <> "/" <> struct.arity
  end
end

defimpl Jason.Encoder, for: [Iris.Entity.Module.Method.Call] do
  def encode(struct, opts) do
    Jason.Encode.map(
      %{
        "method" => struct.method,
        "clickable" => struct.clickable
      },
      opts
    )
  end
end

defimpl Jason.Encoder, for: Tuple do
  def encode(data, opts) when is_tuple(data) do
    data
    |> Tuple.to_list()
    |> Jason.Encoder.List.encode(opts)
  end
end

defimpl Jason.Encoder, for: Iris.ExDoc.DocNode do
  def encode(struct, opts) do
    try do
      Jason.Encode.map(
        %{
          "id" => struct.id,
          "name" => struct.name,
          "arity" => struct.arity,
          "defaults" => struct.defaults,
          "deprecated" => struct.deprecated,
          "doc" => struct.doc,
          "source_doc" => struct.source_doc,
          "type" => Atom.to_string(struct.type),
          "signature" => struct.signature,
          "annotations" => struct.annotations,
          "group" => struct.group,
          "doc_line" => struct.doc_line,
          "doc_file" => struct.doc_file
        },
        opts
      )
    rescue
      e -> IO.inspect({"ERROR", e})
    end
  end
end

defimpl Jason.Encoder, for: Iris.ExDoc.ModuleNode do
  def encode(struct, opts) do
    Jason.Encode.map(
      %{
        "id" => struct.id,
        "title" => struct.title,
        "nested_context" => struct.nested_context,
        "nested_title" => struct.nested_title,
        "module" => struct.module,
        "group" => struct.group,
        "deprecated" => struct.deprecated,
        "doc_format" => struct.doc_format,
        "doc" => struct.doc,
        "source_doc" => struct.source_doc,
        "moduledoc_line" => struct.moduledoc_line,
        "moduledoc_file" => struct.moduledoc_file,
        "docs_groups" => struct.docs_groups,
        "docs" => struct.docs,
        "typespecs" => struct.typespecs,
        "type" => struct.type,
        "language" => struct.language,
        "annotations" => struct.annotations,
        # "metadata" => struct.metadata
      },
      opts
    )
  end
end
