defmodule IrisWeb.HomeLive do
  use IrisWeb, :live_view

  alias Iris.Interface

  def mount(params, session, socket) do
    IO.inspect(params)
    IO.inspect(session)

    modules = Interface.get_home()

    socket =
      assign(socket, %{
        id: "Table1",
        modules: modules,
        selectedModule: Enum.at(modules, 0),
        showExports: "visible",
        showCode: "hidden"
      })

    {:ok, socket}
  end

  def handle_event("select_module", %{"module" => name} = _params, socket) do
    modules = Interface.get_home()
    selected = Enum.filter(modules, fn mod -> name == mod.module end) |> IO.inspect()

    {:noreply, assign(socket, %{selectedModule: Enum.at(selected, 0)})}
  end

  def handle_event("show_exports", %{"module" => name} = _params, socket) do
    modules = Interface.get_home()
    selected = Enum.filter(modules, fn mod -> name == mod.module end) |> IO.inspect()

    {:noreply,
     assign(socket, %{
       selectedModule: Enum.at(selected, 0),
       showExports: "visible",
       showCode: "hidden"
     })}
  end

  def handle_event("show_code", %{"module" => name} = _params, socket) do
    modules = Interface.get_home()
    selected = Enum.filter(modules, fn mod -> name == mod.module end) |> IO.inspect()

    {:noreply,
     assign(socket, %{
       selectedModule: Enum.at(selected, 0),
       showExports: "hidden",
       showCode: "visible"
     })}
  end
end
