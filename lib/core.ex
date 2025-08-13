defmodule Iris.Core do
  alias Iris.Entity
  alias Iris.Entity.Module
  alias Iris.Entity.Application
  alias Iris.Entity.Module.Method
  alias Iris.Entity.Module.Method.Call

  def build(config) do
    files = get_beam_files(config)
    modules = Enum.map(files, &build_from_beam_file/1)
    apps = build_applications(modules)

    IO.inspect("ALL MODULES")
    Enum.each(apps, fn app -> Enum.each(app.modules, fn mod -> IO.inspect(mod.module) end) end)

    all_methods = flatten_all_methods(apps)

    all_out_calls =
      Enum.reduce(all_methods, %{}, fn method, acc ->
        calls =
          get_out_calls(method.call_instructions)
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
      |> Enum.into(%{}, fn {callee, callers} ->
        # generate %Call{} from %Method{} caller
        # Always clickable since they are not BIF/IMP methods
        calls = Enum.map(callers, &Call.new(&1, true))

        {callee, calls}
      end)

    apps =
      Enum.map(apps, fn app ->
        modules =
          Enum.map(
            app.modules,
            &assign_in_out_calls(&1, all_methods, all_out_calls, all_in_calls)
          )

        %Application{app | modules: modules}
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

  defp build_from_beam_file({beam_bin, file}) do
    {:beam_file, mod_name, labeled_exports, _attributes, _compile_info, compiled_code} = file

    # private methods grouped by {name, arity}
    locals_map = extract_locals_from_beam(beam_bin)

    # exported methods - group labeled exports by {name, arity}
    labeled_exports_map =
      labeled_exports
      |> Enum.group_by(fn {name, arity, _label} ->
        {Atom.to_string(name), Integer.to_string(arity)}
      end)

    mod_name_str = mod_name |> Atom.to_string() |> String.split("Elixir.") |> Enum.at(1)

    methods =
      build_methods(compiled_code, mod_name_str)
      |> condense_methods()
      |> filter_auto_generated()
      |> assign_html_type_text(labeled_exports_map, locals_map, mod_name_str)
      |> sort_methods()

    # return
    %Module{
      application: String.split(mod_name_str, ".") |> Enum.at(0),
      module: mod_name_str,
      methods: methods,
      ex_doc: "" # TODO: take help of ex_doc for this.
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
          actual_method = Map.get(acc, {name, arity})

          actual_method = %Method{
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
    |> Enum.filter(fn method ->
      # all methods that do not match the following regex.
      # this is the same regex used in [extract_name_from_auto_generated/2]
      !(Regex.match?(~r/^-inlined(.*)-$/, method.name) ||
          Regex.match?(~r/^-(.*)-(fun|inlined)-(.*)-$/, method.name))
    end)
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
  defp assign_html_type_text(methods, exports_map, locals_map, mod_name_str) do
    methods
    |> Enum.map(fn method ->
      cond do
        Map.has_key?(exports_map, {method.name, method.arity}) ->
          %Method{method | is_export: true, html_type_text: "EXP", view: true}

        Map.has_key?(locals_map, {method.name, method.arity}) ->
          %Method{method | html_type_text: "INT", view: true}

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

  def get_beam_files(config) do
    main_mod = Keyword.get(config, :app) |> Atom.to_string()
    path = File.cwd!() <> "/_build/dev/lib/" <> main_mod <> "/ebin/"

    files =
      path
      |> list_beam_files()

    files =
      for file <- files do
        bin = File.read!(path <> file)
        beam_file = :beam_disasm.file(bin)

        {bin, beam_file}
      end

    files
  end

  defp list_beam_files(path) do
    File.ls!(path)
    |> Enum.filter(fn name -> String.contains?(name, ".beam") end)
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
          _ -> nil
        end

      ret
    end)
    |> Enum.filter(fn val -> val != nil end)
  end

  # returns the instruction in {m,f,a} format
  # see [get_call_instructions/1] return type to understand [instructions] format
  defp get_out_calls(instructions) do
    instructions
    |> Enum.map(fn instr ->
      case instr do
        {_call_inst, _arity, {:extfunc, m, f, a}} ->
          {m, f, a}

        {_call_inst, _arity, {m, f, a}} ->
          {m, f, a}

        inst ->
          IO.inspect(
            {"FATAL : EXITING : get_out_calls Not implemented for instruction type ", inst}
          )

          System.halt(1)
      end
    end)
    |> Enum.map(fn {m, f, a} -> {Atom.to_string(m), Atom.to_string(f), a} end)
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

    %Module{module | out_calls: module_out_calls, in_calls: module_in_calls}
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
      [] ->
        method = %Method{module: call_m, name: call_f, arity: call_a}

        method =
          case call_m do
            "erlang" -> %Method{method | html_type_text: "BIF"}
            _ -> %Method{method | html_type_text: "IMP"}
          end

        %Call{clickable: false, method: method}

      [method] ->
        %Call{clickable: true, method: method}
    end
  end
end
