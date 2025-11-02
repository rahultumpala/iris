defmodule Iris.Core do
  alias Iris.{Entity, Entity.Module, Entity.Application}
  alias Iris.Entity.Module.{Method, Method.Call}
  alias Iris.DocGen

  @doc ~S"""
   Main entry pont.
  """
  def build(config) do
    files = get_beam_files(config)
    modules = Enum.map(files, &build_from_beam_file(&1, config))
    apps = build_applications(modules)

    if config.verbose do
      Mix.shell().info("All modules: ")
      Enum.each(apps, fn app -> Enum.each(app.modules, fn mod -> IO.inspect(mod.module) end) end)
    end

    all_methods = flatten_all_methods(apps)

    # key = %Method{}, value = [%Call{}, %Call{}..]
    all_out_calls =
      Enum.reduce(all_methods, %{}, fn method, acc ->
        calls =
          method.call_instructions
          |> Enum.map(&generate_call(&1, all_methods))

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
            &assign_in_out_calls(&1, all_methods, all_out_calls, all_in_calls)
          )

        %{app | modules: modules}
      end)

    %Entity{
      applications: apps,
      all_out_calls: all_out_calls
    }
  end

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

    module_doc = DocGen.generate_docs(mod_name, config)
    # group method docs by {name}/{arity} as key
    method_docs = module_doc |> group_method_docs()

    methods =
      build_methods(compiled_code, mod_name_str)
      |> condense_methods()
      # |> IO.inspect()
      |> filter_auto_generated()
      |> assign_html_type_text(labeled_exports_map, locals_map)
      |> sort_methods()
      |> Enum.map(&normalize_call_instructions/1)
      |> Enum.map(&filter_recursive_calls/1)
      |> Enum.map(&filter_duplicate_calls/1)
      |> Enum.map(&set_method_docs(&1, method_docs))
      |> Enum.sort_by(fn %Method{name: name, arity: arity} ->
        Enum.join([name, arity], "/")
      end)

    # set docs as null to avoid repetition
    module_doc = with %Iris.ExDoc.ModuleNode{} <- module_doc, do: %{module_doc | docs: nil}

    module_doc =
      cond do
        filter_empty_docs(module_doc) != false -> module_doc
        # return nil when filter evaluates to false
        true -> nil
      end

    # return
    %Module{
      application: String.split(mod_name_str, ".") |> Enum.at(0),
      module: mod_name_str,
      methods: methods,
      ex_doc: module_doc
    }
  end

  # Extracts defined private methods from beam binary, groups them by {name, arity} and returns a map.
  defp extract_locals_from_beam(beam_bin) do
    {:ok, {_, [{:locals, local_methods}]}} =
      :beam_lib.chunks(beam_bin, [:locals])

    locals_map =
      Enum.map(local_methods, fn {name, arity} -> {Atom.to_string(name), arity} end)
      |> Enum.filter(fn {name, _arity} -> !String.starts_with?(name, "-") end)
      |> Enum.group_by(fn {name, arity} -> {name, arity} end)

    locals_map
  end

  # builds a list of %Method{} from compiled_code extracted from beam binary
  defp build_methods(compiled_code, mod_name_str) do
    compiled_code
    |> Enum.map(fn {type, name, arity, _label, code} ->
      %Method{
        name: Atom.to_string(name),
        arity: Integer.to_string(arity),
        module: mod_name_str,
        type: Atom.to_string(type),
        compiled_code: code,
        call_instructions: code |> get_call_instructions()
      }
    end)
  end

  # Condense auto generated inlined, intermediate methods into the actual one
  # expects method list with each item being %Method{} struct
  defp condense_methods(methods) do
    # turns list into map
    methods =
      methods
      |> Enum.reduce(%{}, fn method, acc ->
        {name, arity} = {method.name, method.arity}
        {name, arity} = extract_name_from_auto_generated(name, arity)

        # append call instructions if already found one method (auto generated or actual) with same name
        if Map.has_key?(acc, {name, arity}) do
          %Method{} = actual_method = Map.get(acc, {name, arity})

          actual_method = %{
            actual_method
            | call_instructions: actual_method.call_instructions ++ method.call_instructions
          }

          # return new acc with updated method
          Map.put(acc, {name, arity}, actual_method)
        else
          # put method in acc with {name, arity} as key
          Map.put(acc, {name, arity}, method)
        end
      end)

    # reverts map into list
    methods = Map.values(methods)

    methods
  end

  # filters auto generated methods
  # these methods are condensed into actual defined ones in [condense_methods/2]
  # and are no longer required to be part of [methods] list
  defp filter_auto_generated(methods) do
    methods
    |> Enum.filter(&is_name_not_autogenerated?(&1.name))
  end

  defp is_name_not_autogenerated?(name) do
    # all methods that do not match the following regex.
    # this is the same regex used in [extract_name_from_auto_generated/2]
    !(Regex.match?(~r/^-inlined(.*)-$/, name) ||
        Regex.match?(~r/^-(.*)-(fun|inlined)-(.*)-$/, name))
  end

  # returns {name, arity} from auto generated methods
  # "-inlined-__help__/1-" --> {"__help__", 1}
  # "-build_applications/1-(fun|inlined)-1-" --> {"build_applications", 1}
  defp extract_name_from_auto_generated(name, arity) do
    cond do
      # anchors ^ and $ for precision matching
      Regex.match?(~r/^-inlined(.*)-$/, name) ->
        %{"name" => name, "arity" => arity} =
          Regex.named_captures(~r/(-inlined-)(?<name>.*)\/(?<arity>.*)-/, name)

        {name, arity}

      Regex.match?(~r/^-(.*)-(fun|inlined)-(.*)-$/, name) ->
        %{"name" => name, "arity" => arity} =
          Regex.named_captures(~r/^(-)(?<name>.*)\/(?<arity>.*)-(fun|inlined)-(.*)-/, name)

        {name, arity}

      true ->
        {name, arity}
    end
  end

  # assigns the text EXP(when found in exports) or INT(when found in locals)
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

  # sort based on the criteria EXP > INT
  defp sort_methods(methods) do
    methods
    |> Enum.sort(fn ma, mb ->
      case {ma.html_type_text, mb.html_type_text} do
        {"EXP", "INT"} -> true
        _ -> false
      end
    end)
  end

  @doc ~S"""
    Fetches generated .beam files from local build directory
    and dissassembles them using :beam_disasm
  """
  def get_beam_files(config) do
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

  defp list_beam_files(path) do
    Path.wildcard(Path.expand("*.beam", path))
  end

  # All call instructions that can be extracted from compiled code
  # returns a list of instructions
  # format { type, arity, function }
  # function -> {module, function, arity}
  defp get_call_instructions(code) do
    code
    |> Enum.map(fn instruction ->
      ret =
        case instruction do
          {:call, a, f} -> {:call, a, f}
          {:call_last, a, f, _n} -> {:call_last, a, f}
          {:call_ext_last, a, f, _n} -> {:call_ext_last, a, f}
          {:call_only, a, f} -> {:call_only, a, f}
          {:call_ext_only, a, f} -> {:call_ext_only, a, f}
          # methods that are referenced using the capture operator notation &method_name/arity
          # show up in :make_fun3 instruction along with autogenerated/inlned methods
          {:make_fun3, f, _, _, _, _} -> {:make_fun3, f}
          _ -> nil
        end

      ret
    end)
    |> Enum.filter(fn val -> val != nil end)
  end

  # returns the instruction in {m,f,a} format
  # see [get_call_instructions/1] return type to understand instruction format
  defp normalize_call_instructions(%Method{} = method) do
    normalized_instr =
      method.call_instructions
      |> Enum.map(fn instr ->
        case instr do
          {_call_inst, _arity, {:extfunc, m, f, a}} ->
            {m, f, a}

          {_call_inst, _arity, {m, f, a}} ->
            {m, f, a}

          {:make_fun3, {m, f, a}} ->
            {m, f, a}

          inst ->
            IO.inspect(
              {"FATAL : EXITING : [normalize_call_instructions/1] not implemented for instruction type ",
               inst}
            )

            System.halt(1)
        end
      end)
      |> Enum.map(fn {m, f, a} -> {Atom.to_string(m), Atom.to_string(f), a} end)
      # make_fun3 generates inlined methods as well so filter them out
      |> Enum.filter(fn {_m, f, _a} -> is_name_not_autogenerated?(f) end)
      |> Enum.map(fn {m, f, a} ->
        cond do
          String.starts_with?(m, "Elixir.") ->
            m = m |> String.split("Elixir.") |> Enum.at(1)
            {m, f, a}

          true ->
            {m, f, a}
        end
      end)
      |> Enum.map(fn {m, f, a} ->
        # using Integer.to_string to avoid inequality during comparison while generating calls
        # todo: fix this. standardize arity as string/integer in the entire code.
        {f, a} = extract_name_from_auto_generated(f, Integer.to_string(a))
        {m, f, a}
      end)

    %{method | call_instructions: normalized_instr}
  end

  # divides instructions into recursive and non-recursive
  # if more than one recursive instruction is found method is flagged as recursive and only non_recursive instructions are returned
  # else return all instructions
  defp filter_recursive_calls(%Method{} = method) do
    {recursive_calls, non_recursive_calls} =
      method.call_instructions
      |> Enum.reduce({[], []}, fn {m, f, a} = call, {rec, non_rec} ->
        cond do
          m == method.module && f == method.name && a == method.arity -> {[call | rec], non_rec}
          true -> {rec, [call | non_rec]}
        end
      end)

    case recursive_calls do
      [] -> method
      _ -> %{method | call_instructions: non_recursive_calls, is_recursive: true}
    end
  end

  # remove duplicate instructions
  defp filter_duplicate_calls(%Method{} = method) do
    %{method | call_instructions: Enum.uniq(method.call_instructions)}
  end

  defp flatten_all_methods(apps) do
    Enum.reduce(apps, [], fn app, acc ->
      Entity.Application.get_all_methods(app) ++ acc
    end)
  end

  defp assign_in_out_calls(
         %Iris.Entity.Module{} = module,
         all_methods,
         all_out_calls,
         all_in_calls
       ) do
    module_methods = Enum.filter(all_methods, fn method -> method.module == module.module end)

    module_out_calls =
      Enum.reduce(module_methods, %{}, fn method, acc ->
        Map.put(acc, method, Map.get(all_out_calls, method, []))
      end)

    module_in_calls =
      Enum.reduce(module_methods, %{}, fn method, acc ->
        Map.put(acc, method, Map.get(all_in_calls, method, []))
      end)

    %{module | out_calls: module_out_calls, in_calls: module_in_calls}
  end

  defp set_method_docs(%Method{} = method, %{} = method_docs) do
    key = method.name <> "/" <> method.arity

    case Map.get(method_docs, key, nil) do
      nil -> method
      doc -> %{method | ex_doc: doc}
    end

    with doc <- Map.get(method_docs, key, nil),
         false <- is_nil(doc),
         false <- doc.source_doc == :none do
      %{method | ex_doc: doc}
    else
      _ -> method
    end
  end

  defp generate_call(%Method{} = caller, all_methods) do
    generate_call({caller.module, caller.name, caller.arity}, all_methods)
  end

  defp generate_call(_call = {call_m, call_f, call_a}, all_methods) do
    select =
      all_methods
      |> Enum.filter(fn m ->
        m.module == call_m && m.name == call_f && m.arity == call_a
      end)

    case select do
      # checks whether the method is part of current project
      # if empty then it must be a built-in-function
      # or method imported from a dependency
      [] ->
        method = %Method{module: call_m, name: call_f, arity: call_a}

        method =
          case call_m do
            "erlang" -> %{method | html_type_text: "BIF"}
            _ -> %{method | html_type_text: "IMP"}
          end

        %Call{clickable: false, method: method}

      # method is part of current project
      # no need to change html_type_text.
      [method] ->
        %Call{clickable: true, method: method}
    end
  end

  defp group_method_docs(module_doc) do
    # group method docs by {name}/{arity} as key from module docs node
    case module_doc do
      nil ->
        %{}

      %Iris.ExDoc.ModuleNode{} ->
        module_doc.docs
        # remove empty doc structs
        |> Enum.filter(&filter_empty_docs/1)
        |> Enum.reduce(%{}, fn method_doc, acc ->
          key = Atom.to_string(method_doc.name) <> "/" <> Integer.to_string(method_doc.arity)
          Map.put(acc, key, method_doc)
        end)
    end
  end

  defp filter_empty_docs(doc) do
    case doc do
      %Iris.ExDoc.ModuleNode{} -> doc.source_doc != :none
      %Iris.ExDoc.DocNode{} -> doc.source_doc != :none
      _ -> false
    end
  end
end
