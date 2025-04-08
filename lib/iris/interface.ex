defmodule Iris.Interface do
  alias Iris.Core

  def get_home() do
    Core.build()
  end
end
