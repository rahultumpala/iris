defmodule Iris.Core do
  alias Iris.{Entity, Entity.Module, Entity.Application}
  alias Iris.Entity.Module.{Method, Method.Call}

  import Iris.{Calls, Functions, DocGen}
  import Iris.Utils, only: [log_verbose: 1]

  use IrisDoc

  @doc ~S"""
   Main entry pont.
  """
  def build(config) do
    files = get_beam_files(config)
    modules = Enum.map(files, &build_from_beam_file(&1, config))
    apps = build_applications(modules)

    log_verbose do
      Mix.shell().info("List of apps: ")
      Enum.each(apps, fn app ->  Mix.shell().info("\t#{app.application}") end)
      Mix.shell().info("List of modules: ")
      Enum.each(apps, fn app -> Enum.each(app.modules, fn mod -> Mix.shell().info("\t#{mod.module}") end) end)
    end

    all_functions = flatten_all_functions(apps)

    # key = %Method{}, value = [%Call{}, %Call{}..]
    all_out_calls =
      Enum.reduce(all_functions, %{}, fn method, acc ->
        calls =
          method.call_instructions
          |> Enum.map(&generate_call(&1, all_functions))

        Map.put(acc, method, calls)
      end)

    all_in_calls =
      Enum.reduce(all_out_calls, %{}, fn {caller, callees}, acc ->
        in_calls =
          Enum.reduce(callees, %{}, fn callee, acc ->
            # callee is %Call{} not %Method{} but we want key to be %Method{}
            Map.update(acc, callee.method, [caller], &Kernel.++([caller], &1))
          end)

        Map.merge(acc, in_calls, fn _k, v1, v2 -> v2 ++ v1 end)
      end)
      |> Map.new(fn {callee, callers} ->
        # generate %Call{} from %Method{} caller
        # Always clickable since they are not BIF/IMP methods
        calls = Enum.map(callers, &Call.new(&1, true))

        {callee, calls}
      end)

    apps =
      Enum.map(apps, fn %Application{} = app ->
        modules =
          Enum.map(
            app.modules,
            &assign_in_out_calls(&1, all_functions, all_out_calls, all_in_calls)
          )

        %{app | modules: modules}
      end)

    %Entity{
      applications: apps,
      all_out_calls: all_out_calls
    }
  end

  @idoc ~S"""
    Builds the applications struct by extracting info from the module structs passed as argument.
  """
  defp build_applications(modules) do
    modules
    |> Enum.group_by(fn mod ->
      String.split(mod.module, ".")
      |> Enum.at(0)
    end)
    |> Enum.map(fn {name, modules} ->
      %Application{
        application: name,
        modules: modules
      }
    end)
  end

  defp build_from_beam_file({beam_bin, beam_obj}, config) do
    {:beam_file, mod_name, labeled_exports, _attributes, _compile_info, compiled_code} = beam_obj

    # private methods grouped by {name, arity}
    locals_map = extract_locals_from_beam(beam_bin)

    # exported methods - group labeled exports by {name, arity}
    labeled_exports_map =
      labeled_exports
      |> Enum.group_by(fn {name, arity, _label} ->
        {Atom.to_string(name), Integer.to_string(arity)}
      end)

    mod_name_str =
      mod_name
      |> Atom.to_string()
      |> String.split("Elixir.")
      |> case do
        [_elixir_prefix, mod_name] -> mod_name
        [mod_name] -> mod_name
      end

    module_doc = generate_docs(mod_name, config)
    # group method docs by {name}/{arity} as key
    all_docs = module_doc |> group_function_docs()
    idocs = get_iris_docs_from_module(mod_name)
    all_docs = Map.merge(all_docs, idocs)

    methods =
      build_functions(compiled_code, mod_name_str)
      |> condense_functions()
      |> filter_auto_generated()
      |> assign_html_type_text(labeled_exports_map, locals_map)
      |> sort_functions()
      |> Enum.map(&normalize_call_instructions/1)
      |> Enum.map(&filter_recursive_calls/1)
      |> Enum.map(&filter_duplicate_calls/1)
      |> Enum.map(&set_function_docs(&1, all_docs))
      |> Enum.sort_by(fn %Method{name: name, arity: arity} ->
        Enum.join([name, arity], "/")
      end)

    # set docs as null to avoid repetition
    module_doc = with %Iris.ExDoc.ModuleNode{} <- module_doc, do: %{module_doc | docs: nil}

    %Module{
      application: String.split(mod_name_str, ".") |> Enum.at(0),
      module: mod_name_str,
      methods: methods,
      ex_doc: module_doc
    }
  end

  @idoc ~S"""
    Extracts defined private methods from beam binary, groups them by {name, arity} and returns a map.
  """
  defp extract_locals_from_beam(beam_bin) do
    {:ok, {_, [{:locals, local_methods}]}} =
      :beam_lib.chunks(beam_bin, [:locals])

    locals_map =
      Enum.map(local_methods, fn {name, arity} -> {Atom.to_string(name), arity} end)
      |> Enum.filter(fn {name, _arity} -> !String.starts_with?(name, "-") end)
      |> Enum.group_by(fn {name, arity} -> {name, arity} end)

    locals_map
  end

  @idoc ~S"""
   Assigns the text EXP(when found in exports) or INT(when found in locals)
  """
  defp assign_html_type_text(methods, exports_map, locals_map) do
    methods
    |> Enum.map(fn %Method{} = method ->
      cond do
        Map.has_key?(exports_map, {method.name, method.arity}) ->
          %{method | is_export: true, html_type_text: "EXP", view: true}

        Map.has_key?(locals_map, {method.name, method.arity}) ->
          %{method | html_type_text: "INT", view: true}

        true ->
          method
      end
    end)
  end

  @idoc ~S"""
    Fetches generated .beam files from local build directory
    and dissassembles them using :beam_disasm
  """
  defp get_beam_files(config) do
    # IO.inspect({"CONFIG", config})

    paths = config.source_beam
    files = Enum.map(paths, &list_beam_files/1) |> List.flatten()

    files =
      for fileName <- files do
        bin = File.read!(fileName)
        beam_file = :beam_disasm.file(bin)

        {bin, beam_file}
      end

    files
  end

  @idoc ~S"""
    List all the .beam files from given path.
    path is usually `_build/dev/{app_name}/ebin/`
  """
  defp list_beam_files(path) do
    Path.wildcard(Path.expand("*.beam", path))
  end
end
