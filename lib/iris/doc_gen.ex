defmodule Iris.DocGen do
  @moduledoc ~S"""
  A wrapper around ExDoc lib to fetch documentation in HTML
  """

  alias Iris.ExDoc.Retriever

  def generate_docs(beam_bin, config) do
    case Retriever.get_module(beam_bin, config) do
      {:ok, module_node} ->
        module_node

      {:error, _err} ->
        # IO.inspect({"Error generating module doc for:", err})
        nil
    end
  end
end
