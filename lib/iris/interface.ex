defmodule Iris.Interface do
  alias Iris.Core
  alias Iris.Entity

  def get_home() do
    Core.build()
  end
end
