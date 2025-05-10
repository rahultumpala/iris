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
        "html_type_text" => struct.html_type_text,
        "call_instructions" => struct.call_instructions
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
end

defimpl String.Chars, for: [Iris.Entity.Module.Method] do
  def to_string(struct) do
    # This is used while generating the Key in KV pairs in in_calls & out_calls
    # Will need to modify to prefix Application name too.
    struct.module <> "." <> struct.name
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
