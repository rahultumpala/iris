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
        modules: modules
      })

    {:ok, socket}
  end

  def handle_event(event, unsigned_params, socket) do
    IO.inspect(event)
    IO.inspect(unsigned_params)

    {:ok, socket}
  end
end
