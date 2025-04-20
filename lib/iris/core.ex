defmodule Iris.Core do
  alias Iris.Entity
  alias Iris.Entity.Module
  alias Iris.Entity.Application
  alias Iris.Entity.Module.Method

  def build() do
    files = get_beam_files()
    modules = Enum.map(files, &build_from_beam_file/1)
    apps = build_applications(modules)

    IO.inspect("ALL MODULES")
    Enum.each(apps, fn app -> Enum.each(app.modules, fn mod -> IO.inspect(mod.module) end) end)

    Enum.each(apps, fn app -> find_in_calls(app.modules) end)

    %Entity{
      applications: apps
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
    # Get local methods
    {:ok, {_, [{:locals, local_methods}]}} =
      :beam_lib.chunks(beam_bin, [:locals])

    locals_map =
      Enum.map(local_methods, fn {name, arity} -> {Atom.to_string(name), arity} end)
      |> Enum.filter(fn {name, _arity} -> !String.starts_with?(name, "-") end)
      |> Enum.group_by(fn {name, arity} -> {name, arity} end)

    {:beam_file, mod_name, labeled_exports, _attributes, _compile_info, compiled_code} = file

    mod_name_str = mod_name |> Atom.to_string() |> String.split("Elixir.") |> Enum.at(1)

    labeled_exports_map =
      labeled_exports
      |> Enum.group_by(fn {name, arity, _label} -> {Atom.to_string(name), arity} end)

    code_blocks =
      compiled_code
      |> Enum.map(fn {type, name, arity, _label, code} ->
        out_calls = code |> get_call_instructions() |> get_out_calls()

        name = Atom.to_string(name)

        method = %Method{
          name: name,
          arity: arity,
          module: mod_name_str,
          type: Atom.to_string(type),
          out_calls: out_calls,
          compiled_code: code
        }

        method
      end)

    code_blocks = code_blocks |> Enum.filter(fn method -> method != nil end)

    # Filter out auto generated methods
    auto_generated =
      code_blocks
      |> Enum.filter(fn method ->
        line =
          case method.compiled_code do
            [{:line, number} | _rest] -> number
            _ -> -1
          end

        String.starts_with?(method.name, "-") ||
          String.starts_with?(method.name, "__") ||
          line == 0 ||
          !(Map.has_key?(locals_map, {method.name, method.arity}) ||
              Map.has_key?(labeled_exports_map, {method.name, method.arity}))
      end)
      |> Enum.into(%{}, fn method -> {{method.name, method.arity}, method} end)

    IO.inspect({"AUTO GENERATED", auto_generated})

    code_blocks =
      code_blocks
      |> Enum.map(fn method ->
        cond do
          # Auto Generated Function
          Map.has_key?(auto_generated, {method.name, method.arity}) ->
            %Method{method | html_type_text: "AGF"}

          Map.has_key?(labeled_exports_map, {method.name, method.arity}) ->
            %Method{method | is_export: true, html_type_text: "EXT", view: true}

          Map.has_key?(locals_map, {method.name, method.arity}) ->
            %Method{method | html_type_text: "INT", view: true}
        end
      end)
      |> Enum.map(fn method ->
        %Method{method | ex_doc: get_html_doc(mod_name_str, "#{method.name}/#{method.arity}")}
      end)
      # EXT > INT > AGF
      |> Enum.sort(fn ma, mb ->
        case {ma.html_type_text, mb.html_type_text} do
          {"EXT", "INT"} -> true
          {"EXT", "AGF"} -> true
          {"INT", "AGF"} -> true
          _ -> false
        end
      end)

    %Module{
      module: mod_name_str,
      methods: code_blocks,
      ex_doc: get_html_doc(mod_name_str, "moduledoc")
    }
  end

  def get_beam_files() do
    main_mod = Elixir.Application.get_application(__MODULE__) |> Atom.to_string()
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

  defp get_out_calls(instructions) do
    instructions
    |> Enum.map(fn instr ->
      case instr do
        {_call_inst, _arity, {:extfunc, m, f, a}} ->
          {m, f, a}

        {_call_inst, _arity, {m, f, a}} ->
          {m, f, a}

        inst ->
          IO.inspect("get_out_calls Not implemented for instruction type #{inst}")
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
  end

  defp find_in_calls(modules) do
    all_out_calls =
      Enum.reduce(modules, [], fn mod, acc ->
        out_calls =
          Enum.map(mod.methods, fn method ->
            Enum.map(method.out_calls, fn call ->
              {method, call}
            end)
          end)
          |> List.flatten()

        [out_calls | acc]
      end)
      |> List.flatten()

    # IO.inspect({"ALL OUT_CALLS in ALL MODULES", all_out_calls})

    in_calls =
      Enum.reduce(all_out_calls, %{}, fn {caller, callee}, acc ->
        Map.update(acc, callee, [], fn val -> [caller | val] end)
      end)

    # IO.inspect({"ALL IN_CALLS in ALL MODULES", in_calls})

    in_calls
  end

  defp get_html_doc(mod_name_str, selector) do
    with {:ok, cwd} <- File.cwd(),
         doc_path <- cwd <> "/doc",
         file_path <- doc_path <> "/#{mod_name_str}.html",
         true <- File.dir?(doc_path),
         true <- File.exists?(file_path),
         {:ok, html} <- File.read(file_path),
         {:ok, document} <- Floki.parse_document(html) do
      case Floki.get_by_id(document, selector) do
        nil -> nil
        html_node -> Floki.raw_html(html_node)
      end
    else
      # match any un expected result and return nil
      _ -> nil
    end
  end
end
