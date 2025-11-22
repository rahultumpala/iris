defmodule Iris.DocGen do
  use IrisDoc

  @moduledoc ~S"""
  A wrapper around ExDoc Retriever module to fetch documentation in HTML
  and some functions to fetch docs from the @idoc attribute.
  """

  alias Iris.ExDoc.Retriever

  @doc ~S"""
    Retrieves docs for functions defined in a module, from the .beam file.
  """
  @spec generate_docs(atom() | binary(), any()) :: nil | Iris.ExDoc.ModuleNode.t()
  def generate_docs(beam_bin, config) do
    case Retriever.get_module(beam_bin, config) do
      {:ok, module_node} ->
        module_node

      {:error, _err} ->
        # IO.inspect({"Error generating module doc for:", err})
        nil
    end
  end

  @doc ~S"""
    Group docs for functions that have docs by the function name and arity.
    returns a map with key = "fn_name/arity" and value = documentation
  """
  def group_function_docs(module_doc) do
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

  @idoc "Ensure there are no empty docs"
  defp filter_empty_docs(doc) do
    case doc do
      %Iris.ExDoc.ModuleNode{} -> doc.source_doc != :none
      %Iris.ExDoc.DocNode{} -> doc.source_doc != :none
      _ -> false
    end
  end

  @doc ~S"""
    Fetches the value of @idoc attribute defined before private functions.
    Returns as a map with key = function_name/arity
    and value = documentation
  """
  def get_iris_docs_from_module(module) do
    uses_iris_docs =
      module.__info__(:functions)
      |> Keyword.filter(fn {key, _val} -> key == :__idocs__ end)
      |> length() > 0

    cond do
      uses_iris_docs ->
        module.__idocs__()
        |> Map.new(fn {f_name, arity, doc} ->
          # return in {key, value} notation
          key = "#{f_name}/#{arity}"

          # Creating a new DocNode to avoid breaking things as ExDoc already returns in this format.
          doc_node = %Iris.ExDoc.DocNode{
            id: key,
            name: f_name,
            arity: arity,
            source_doc: %{"en" => doc}
          }

          {key, doc_node}
        end)

      true ->
        %{}
    end
  end
end
