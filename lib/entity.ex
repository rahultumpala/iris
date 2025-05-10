defmodule Iris.Entity do
  defstruct applications: [],
            all_out_calls: []

  def new(),
    do: %Iris.Entity{
      applications: []
    }
end

defmodule Iris.Entity.Application do
  defstruct [
    :application,
    modules: []
  ]

  def new(), do: %Iris.Entity.Application{}

  def get_all_methods(%__MODULE__{} = app) do
    Enum.reduce(app.modules, [], fn module, acc ->
      module.methods ++ acc
    end)
  end
end

defmodule Iris.Entity.Module do
  defstruct [
    :module,
    :application,
    :ex_doc,
    methods: [],
    in_calls: %{},
    out_calls: %{}
  ]

  def new(), do: %Iris.Entity.Module{}

  defmodule Method do
    defstruct [
      :name,
      :arity,
      :module,
      :compiled_code,
      :type,
      :ex_doc,
      view: false,
      is_export: false,
      html_type_text: "INT",
      call_instructions: []
    ]

    def new(), do: %Iris.Entity.Module.Method{}

    defmodule Call do
      defstruct [
        :method,
        clickable: false
      ]

      def new(%Method{} = method, clickable),
        do: %Iris.Entity.Module.Method.Call{method: method, clickable: clickable}
    end
  end
end
