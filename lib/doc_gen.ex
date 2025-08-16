defmodule Iris.DocGen do
  @moduledoc ~S"""
  A wrapper around ExDoc lib to fetch documentation in HTML
  """

  alias ExDoc.Retriever

  def generate_docs(beam_bin, config) do
    Retriever.get_module(beam_bin, config)
  end
end
