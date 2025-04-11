defmodule Iris.Entity do
  defstruct [:applications]

  def new() do
    %Iris.Entity{
      applications: []
    }
  end
end

defmodule Iris.Entity.Application do
  defstruct [:application, :modules]

  def new() do
    %Iris.Entity.Application{}
  end
end

defmodule Iris.Entity.Module do
  defstruct [:module, :exports, :application]

  def new() do
    %Iris.Entity.Module{}
  end

  defmodule Method do
    defstruct [
      :name,
      :arity,
      :module,
      :code,
      :compiled_code,
      :type,
      is_export: false
    ]

    def new() do
      %Iris.Entity.Module.Method{}
    end
  end
end
