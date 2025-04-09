defmodule Iris.Core do
  alias Iris.Entity
  alias Iris.Entity.Module
  alias Iris.Entity.Application
  alias Iris.Entity.Module.Method

  def build() do
    files = get_beam_files()
    modules = Enum.map(files, &build_from_beam_file/1)
    apps = build_applications(modules)

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
    {:beam_file, mod_name, labeled_exports, _attributes, _compile_info, _code} = file

    mod_name = mod_name |> Atom.to_string() |> String.split("Elixir.") |> Enum.at(1)

    exports =
      labeled_exports
      |> Enum.map(fn {name, arity, _label} ->
        %Method{
          name: Atom.to_string(name),
          arity: arity,
          module: mod_name
        }
      end)

    %Module{
      module: mod_name,
      exports: exports
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
end
