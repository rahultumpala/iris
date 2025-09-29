defmodule Iris.ExDoc.Language.Elixir do
  @moduledoc false

  @behaviour Iris.ExDoc.Language

  alias Iris.ExDoc.Language.Source

  @impl true
  @spec module_data(atom, any, any) ::
          false
          | %{
              docs: any,
              id: binary,
              language: Iris.ExDoc.Language.Erlang,
              source_line: pos_integer,
              source_file: Path.t(),
              source_basedir: Path.t(),
              module: module,
              nesting_info: nil,
              private: %{
                abst_code: any,
                callbacks: map,
                impls: map,
                optional_callbacks: any,
                specs: map
              },
              title: binary,
              type: :module | :behaviour | :task | :protocol | :implementation | :exception
            }
  def module_data(module, docs_chunk, config) do
    {type, skip} = module_type_and_skip(module)

    cond do
      skip ->
        false

      abst_code = Source.get_abstract_code(module) ->
        title = module_title(module, type)

        source_basedir = Source.fetch_basedir!(abst_code, module)

        {source_file, source_line} =
          Source.fetch_module_location!(abst_code, source_basedir, module)

        optional_callbacks = Source.get_optional_callbacks(module, type)

        %{
          module: module,
          default_groups: ~w(Types Callbacks Functions),
          docs: docs_chunk,
          language: __MODULE__,
          id: inspect(module),
          title: title,
          type: type,
          source_line: source_line,
          source_file: source_file,
          source_basedir: source_basedir,
          nesting_info: nesting_info(title, config.nest_modules_by_prefix),
          private: %{
            abst_code: abst_code,
            specs: Source.get_specs(abst_code, source_basedir),
            callbacks: Source.get_callbacks(abst_code, source_basedir),
            impls: get_impls(module),
            optional_callbacks: optional_callbacks
          }
        }

      true ->
        Iris.ExDoc.Utils.warn(
          "skipping docs for module #{inspect(module)}, reason: :no_debug_info",
          []
        )

        false
    end
  end

  @impl true
  def doc_data(entry, %{type: type} = module_data) do
    case entry do
      {_key, _anno, _sig, :hidden, _metadata} ->
        false

      {{_kind, name, _arity}, _anno, _sig, _doc, _metadata}
      when name in [:impl_for, :impl_for!] and type == :protocol ->
        false

      {{kind, _, _}, _anon, _sig, _doc, _metadata} when kind in [:function, :macro] ->
        function_data(entry, module_data)

      {{kind, _, _}, _anon, _sig, _doc, _metadata}
      when kind in [:callback, :macrocallback] and type != :protocol ->
        callback_data(entry, module_data)

      {{:type, _, _}, _anon, _sig, _doc, _metadata} ->
        type_data(entry, module_data)

      _ ->
        false
    end
  end

  defp function_data(entry, module_data) do
    {{kind, name, arity}, anno, signature, _doc_content, metadata} = entry

    extra_annotations =
      case {kind, name, arity} do
        {:macro, _, _} -> ["macro"]
        {_, :__struct__, _} -> ["struct"]
        _ -> []
      end

    actual_def = actual_def(name, arity, kind)

    %{
      id_key: "",
      default_group: "Functions",
      doc_fallback: fn ->
        impl = Map.fetch(module_data.private.impls, actual_def)
        callback_doc_ast(name, arity, impl) || delegate_doc_ast(metadata[:delegate_to])
      end,
      extra_annotations: extra_annotations,
      signature: signature,
      source_file: nil,
      source_line: find_function_line(module_data, actual_def) || Source.anno_line(anno),
      specs: specs(kind, name, actual_def, module_data),
      type: kind
    }
  end

  defp callback_data(entry, module_data) do
    {{kind, name, arity}, anno, _signature, _doc, _metadata} = entry
    actual_def = actual_def(name, arity, kind)

    extra_annotations =
      if actual_def in module_data.private.optional_callbacks, do: ["optional"], else: []

    {anno, specs} =
      case module_data.private.callbacks do
        %{^actual_def => {:attribute, anno, :callback, {_name, specs}}} ->
          {anno,
           if kind == :macrocallback do
             Enum.map(specs, &remove_callback_term/1)
           else
             specs
           end}

        %{} ->
          {anno, []}
      end

    line = Source.anno_line(anno)
    quoted = Enum.map(specs, &Code.Typespec.spec_to_quoted(name, &1))
    signature = [get_typespec_signature(hd(quoted), arity)]

    %{
      id_key: "c:",
      default_group: "Callbacks",
      doc_fallback: fn -> nil end,
      extra_annotations: extra_annotations,
      signature: signature,
      source_file: nil,
      source_line: line,
      specs: quoted,
      type: kind
    }
  end

  defp remove_callback_term({:type, num, :bounded_fun, [lhs, rhs]}) do
    {:type, num, :bounded_fun, [remove_callback_term(lhs), rhs]}
  end

  defp remove_callback_term({:type, num, :fun, [{:type, num, :product, [_ | rest_args]} | rest]}) do
    {:type, num, :fun, [{:type, num, :product, rest_args} | rest]}
  end

  defp type_data(entry, module_data) do
    {{_kind, name, arity}, _anno, _signature, _doc, _metadata} = entry

    %{type: type, spec: spec, source_file: source, source_line: line} =
      Source.fetch_type!(module_data, name, arity)

    quoted = spec |> Code.Typespec.type_to_quoted() |> process_type_ast(type)
    signature = [get_typespec_signature(quoted, arity)]

    %{
      id_key: "t:",
      default_group: "Types",
      doc_fallback: fn -> nil end,
      extra_annotations: [],
      source_file: source,
      source_line: line,
      signature: signature,
      specs: [quoted],
      type: type
    }
  end

  @impl true
  def parse_module_function(string) do
    case string |> String.split(".") |> Enum.reverse() do
      [string] ->
        with {:function, function} <- parse_function(string) do
          {:local, function}
        end

      ["", "", ""] ->
        {:local, :..}

      ["//", "", ""] ->
        {:local, :..//}

      ["", ""] ->
        {:local, :.}

      ["", "", "" | rest] ->
        module_string = rest |> Enum.reverse() |> Enum.join(".")

        with {:module, module} <- parse_module(module_string, :custom_link) do
          {:remote, module, :..}
        end

      ["", "" | rest] ->
        module_string = rest |> Enum.reverse() |> Enum.join(".")

        with {:module, module} <- parse_module(module_string, :custom_link) do
          {:remote, module, :.}
        end

      [function_string | rest] ->
        module_string = rest |> Enum.reverse() |> Enum.join(".")

        with {:module, module} <- parse_module(module_string, :custom_link),
             {:function, function} <- parse_function(function_string) do
          {:remote, module, function}
        end
    end
  end

  # There are special forms that are forbidden by the tokenizer
  defp parse_function("__aliases__"), do: {:function, :__aliases__}
  defp parse_function("__block__"), do: {:function, :__block__}
  defp parse_function("%"), do: {:function, :%}

  defp parse_function(string) do
    case Code.string_to_quoted("& #{string}/0", warnings: false) do
      {:ok, {:&, _, [{:/, _, [{function, _, _}, 0]}]}} when is_atom(function) ->
        {:function, function}

      _ ->
        :error
    end
  end

  @impl true
  def parse_module(<<first>> <> _ = string, _mode) when first in ?A..?Z do
    if string =~ ~r/^[A-Za-z0-9_.]+$/ do
      do_parse_module(string)
    else
      :error
    end
  end

  def parse_module(":" <> _ = string, :custom_link) do
    do_parse_module(string)
  end

  def parse_module(_, _) do
    :error
  end

  defp do_parse_module(string) do
    case Code.string_to_quoted(string, warn_on_unnecessary_quotes: false, emit_warnings: false) do
      {:ok, module} when is_atom(module) ->
        {:module, module}

      {:ok, {:__aliases__, _, parts}} ->
        if Enum.all?(parts, &is_atom/1) do
          {:module, Module.concat(parts)}
        else
          :error
        end

      _ ->
        :error
    end
  end

  @impl true
  def highlight_info() do
    %{
      language_name: "elixir",
      lexer: Makeup.Lexers.ElixirLexer,
      opts: []
    }
  end

  @impl true
  def format_spec_attribute(%{type: :type}), do: "@type"
  def format_spec_attribute(%{type: :opaque}), do: "@opaque"
  def format_spec_attribute(%{type: :nominal}), do: "@nominal"
  def format_spec_attribute(%{type: :callback}), do: "@callback"
  def format_spec_attribute(%{type: :macrocallback}), do: "@macrocallback"
  def format_spec_attribute(%{}), do: "@spec"

  ## Module Helpers

  defp nesting_info(title, prefixes) do
    prefixes
    |> Enum.find(&String.starts_with?(title, &1 <> "."))
    |> case do
      nil -> nil
      prefix -> {"." <> String.trim_leading(title, prefix <> "."), prefix}
    end
  end

  defp module_type_and_skip(module) do
    cond do
      function_exported?(module, :__info__, 1) and
          Enum.any?(module.__info__(:struct) || [], &(&1.field == :__exception__)) ->
        {:exception, false}

      function_exported?(module, :__protocol__, 1) ->
        {:protocol, false}

      function_exported?(module, :__impl__, 1) ->
        {:impl, true}

      match?("Elixir.Mix.Tasks." <> _, Atom.to_string(module)) ->
        {:task, false}

      function_exported?(module, :behaviour_info, 1) ->
        {:behaviour, false}

      true ->
        {:module, false}
    end
  end

  defp module_title(module, :task), do: "mix " <> task_name(module)
  defp module_title(module, _), do: inspect(module)

  defp task_name(module) do
    "Elixir.Mix.Tasks." <> name = Atom.to_string(module)
    name |> String.split(".") |> Enum.map_join(".", &Macro.underscore/1)
  end

  def get_impls(module) do
    for behaviour <- behaviours_implemented_by(module),
        abstract_code = Source.get_abstract_code(behaviour),
        {callback, _} <- Source.get_callbacks(abstract_code, ""),
        do: {callback, behaviour},
        into: %{}
  end

  defp behaviours_implemented_by(module) do
    for {:behaviour, list} <- module.module_info(:attributes),
        behaviour <- list,
        do: behaviour
  end

  ## Helpers

  defp specs(kind, name, actual_def, module_data) do
    specs =
      module_data.private.specs
      |> Map.get(actual_def)
      |> then(fn
        {:attribute, _anno, :spec, {_name, type}} -> type
        nil -> []
      end)
      |> Enum.map(&Code.Typespec.spec_to_quoted(name, &1))

    if kind == :macro do
      Enum.map(specs, &remove_first_macro_arg/1)
    else
      specs
    end
  end

  defp actual_def(name, arity, :macrocallback) do
    {String.to_atom("MACRO-" <> to_string(name)), arity + 1}
  end

  defp actual_def(name, arity, :macro) do
    {String.to_atom("MACRO-" <> to_string(name)), arity + 1}
  end

  defp actual_def(name, arity, _), do: {name, arity}

  defp remove_first_macro_arg({:"::", info, [{name, info2, [_term_arg | rest_args]}, return]}) do
    {:"::", info, [{name, info2, rest_args}, return]}
  end

  defp remove_first_macro_arg({:when, meta, [lhs, rhs]}) do
    {:when, meta, [remove_first_macro_arg(lhs), rhs]}
  end

  defp delegate_doc_ast({m, f, a}) do
    [
      {:p, [],
       ["See ", {:code, [class: "inline"], [Exception.format_mfa(m, f, a)], %{line: 1}}, "."],
       %{}}
    ]
  end

  defp delegate_doc_ast(nil) do
    nil
  end

  defp callback_doc_ast(name, arity, {:ok, behaviour}) do
    [
      {:p, [],
       [
         "Callback implementation for ",
         {:code, [class: "inline"], ["c:#{inspect(behaviour)}.#{name}/#{arity}"], %{}},
         "."
       ], %{}}
    ]
  end

  defp callback_doc_ast(_, _, _) do
    nil
  end

  defp find_function_line(module_data, na) do
    {_source, line} = Source.fetch_function_location!(module_data, na)
    line
  end

  defp get_typespec_signature({:when, _, [{:"::", _, [{name, meta, args}, _]}, _]}, arity) do
    Macro.to_string({name, meta, strip_types(args, arity)})
  end

  defp get_typespec_signature({:"::", _, [{name, meta, args}, _]}, arity) do
    Macro.to_string({name, meta, strip_types(args, arity)})
  end

  defp get_typespec_signature({name, meta, args}, arity) do
    Macro.to_string({name, meta, strip_types(args, arity)})
  end

  defp strip_types(args, arity) do
    args
    |> Enum.take(-arity)
    |> Enum.with_index(1)
    |> Enum.map(fn
      {{:"::", _, [left, _]}, position} -> to_var(left, position)
      {{:|, _, _}, position} -> to_var({}, position)
      {left, position} -> to_var(left, position)
    end)
    |> Macro.prewalk(fn node -> Macro.update_meta(node, &Keyword.delete(&1, :line)) end)
  end

  defp to_var({:%, meta, [name, _]}, _), do: {:%, meta, [name, {:%{}, meta, []}]}
  defp to_var({:%{}, _, _}, _), do: {:map, [], nil}
  defp to_var({name, meta, _}, _) when is_atom(name), do: {name, meta, nil}

  defp to_var({{:., meta, [_module, name]}, _, _args}, _) when is_atom(name),
    do: {name, meta, nil}

  defp to_var([{:->, _, _} | _], _), do: {:function, [], nil}
  defp to_var({:<<>>, _, _}, _), do: {:binary, [], nil}
  defp to_var({:{}, _, _}, _), do: {:tuple, [], nil}
  defp to_var({_, _}, _), do: {:tuple, [], nil}
  defp to_var(integer, _) when is_integer(integer), do: {:integer, [], nil}
  defp to_var(float, _) when is_integer(float), do: {:float, [], nil}
  defp to_var(list, _) when is_list(list), do: {:list, [], nil}
  defp to_var(atom, _) when is_atom(atom), do: {:atom, [], nil}
  defp to_var(_, position), do: {:"arg#{position}", [], nil}

  # Cut off the body of an opaque type while leaving it on a normal type.
  defp process_type_ast({:"::", _, [d | _]}, :opaque), do: d
  defp process_type_ast(ast, _), do: ast

end
