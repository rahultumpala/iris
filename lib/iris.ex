defmodule Iris do
  @moduledoc """
  Iris keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def get_tooltip_text(code) do
    case code do
      "INT" -> "Private method"
      "EXT" -> "Exported method"
      "AGF" -> "Auto generated function"
      "IMP" -> "Imported Function"
      "BIF" -> "Built in Function"
    end
  end
end
