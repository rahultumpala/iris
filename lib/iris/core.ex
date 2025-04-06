defmodule Iris.Core do
  alias Iris.Entity

  @methods_to_filter [:__info__, :module_info]

  def build() do
    files = get_beam_files()
    entities = Enum.map(files, &build_from_beam_file/1)
    entities
  end

  defp build_from_beam_file(file) do
    {:beam_file, mod_name, labeled_exports, attributes, compile_info, code} = file

    mod_name = mod_name |> Atom.to_string()

    exports =
      labeled_exports
      |> Enum.map(fn {name, arity, _label} -> %Entity.Method{name: name, arity: arity} end)

    %Entity{
      module: mod_name,
      exports: exports
    }
  end

  def get_beam_files() do
    main_mod = Application.get_application(__MODULE__) |> Atom.to_string()
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
