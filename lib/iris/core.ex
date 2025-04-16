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

  defp build_from_beam_file(file) do
    {:beam_file, mod_name, labeled_exports, _attributes, _compile_info, compiled_code} = file

    mod_name_str = mod_name |> Atom.to_string() |> String.split("Elixir.") |> Enum.at(1)

    labeled_exports_map =
      labeled_exports
      |> Enum.group_by(fn {name, arity, _label} -> {name, arity} end)

    code_blocks =
      compiled_code
      |> Enum.map(fn {type, name, arity, _label, code} ->
        code_str =
          get_calls(code)
          |> calls_to_str()

        method = %Method{
          name: Atom.to_string(name),
          arity: arity,
          module: mod_name_str,
          type: Atom.to_string(type),
          code: code_str,
          compiled_code: compiled_code
        }

        case Map.get(labeled_exports_map, {name, method.arity}, []) do
          [] -> method
          _ -> %Method{method | is_export: true, html_type_text: "EXP"}
        end
      end)

    code_blocks =
      code_blocks
      |> Enum.filter(fn method -> !String.starts_with?(method.name, "-") end)

    %Module{
      module: mod_name_str,
      methods: code_blocks
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
        beam_file
      end

    files
  end

  defp list_beam_files(path) do
    File.ls!(path)
    |> Enum.filter(fn name -> String.contains?(name, ".beam") end)
  end

  defp get_calls(code) do
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

  defp calls_to_str(calls \\ []) do
    Enum.reduce(calls, "", fn x, acc ->
      x
      |> Kernel.inspect()
      |> Kernel.<>("\n\n")
      |> Kernel.<>(acc)
    end)
  end
end
