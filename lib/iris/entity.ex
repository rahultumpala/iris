defmodule Iris.Entity do
  defstruct [:module, :exports, :code]

  def new() do
    %Iris.Entity{}
  end

  defmodule Method do
    defstruct [:name, :arity, is_export: false]
  end
end
