defmodule Iris.State do
  use Agent

  defstruct [
    :selectedApp,
    :selectedModule,
    :selectedMethod,
    :apps,
    :showExports,
    :showCode
  ]

  def new(%Iris.Entity{} = crux) do
    selectedApp = crux.applications |> Enum.at(0)
    selectedMod = selectedApp.modules |> Enum.at(0)
    selectedMethod = selectedMod.methods |> Enum.at(0)

    %Iris.State{
      apps: crux.applications,
      selectedApp: selectedApp,
      selectedModule: selectedMod,
      selectedMethod: selectedMethod,
      showCode: "hidden",
      showExports: "visible"
    }
  end

  def start_link(%Iris.State{} = initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def get do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def select_app(app_name) do
    Agent.update(__MODULE__, fn state ->
      app = Enum.filter(state.apps, fn x -> x.application == app_name end) |> Enum.at(0)
      mod = app.modules |> Enum.at(0)
      selectedMethod = mod.methods |> Enum.at(0)
      %Iris.State{state | selectedApp: app, selectedModule: mod, selectedMethod: selectedMethod}
    end)
  end

  def select_module(module_name) do
    Agent.update(__MODULE__, fn state ->
      app = Enum.filter(state.apps, fn app -> app == state.selectedApp end) |> Enum.at(0)
      mod = Enum.filter(app.modules, fn m -> m.module == module_name end) |> Enum.at(0)
      selectedMethod = mod.methods |> Enum.at(0)
      %Iris.State{state | selectedModule: mod, selectedMethod: selectedMethod}
    end)
  end

  def select_method(method, arity) do
    Agent.update(__MODULE__, fn state ->
      m =
        Enum.filter(state.selectedModule.methods, fn m ->
          m.name == method && Integer.to_string(m.arity) == arity
        end)
        |> Enum.at(0)

      %Iris.State{state | selectedMethod: m}
    end)
  end

  def get_app(name) do
    Agent.get(__MODULE__, fn state ->
      Enum.filter(state.apps, fn app -> app.application == name end)
    end)
  end

  def show_exports() do
    Agent.get(__MODULE__, fn state ->
      %Iris.State{state | showExports: "visible", showCode: "hidden"}
    end)
  end

  def show_code() do
    Agent.get(__MODULE__, fn state ->
      %Iris.State{state | showCode: "visible", showExports: "hidden"}
    end)
  end
end
