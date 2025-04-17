defmodule Iris.Entity do
  defstruct [
    :applications
  ]

  def new() do
    %Iris.Entity{
      applications: []
    }
  end
end

defmodule Iris.Entity.Application do
  defstruct [
    :application,
    :modules
  ]

  def new() do
    %Iris.Entity.Application{}
  end
end

defmodule Iris.Entity.Module do
  defstruct [
    :module,
    :methods,
    :application
  ]

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
      is_export: false,
      html_type_text: "INT"
    ]

    def new() do
      %Iris.Entity.Module.Method{}
    end
  end
end
