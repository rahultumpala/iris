defmodule IrisWeb.HomeLive do
  use IrisWeb, :live_view

  alias Iris.State

  def mount(_params, _session, socket) do
    state = State.get()

    socket =
      assign(socket, %{
        state: state
      })

    {:ok, socket}
  end

  def handle_event("select_app", %{"application" => name} = _params, socket) do
    State.select_app(name)
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("select_module", %{"module" => name} = _params, socket) do
    State.select_module(name)
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("show_exports", _params, socket) do
    State.show_exports()
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("show_code", _params, socket) do
    State.show_code()
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("show_doc", _params, socket) do
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("show_paths", _params, socket) do
    {:noreply, assign(socket, state: State.get())}
  end

  def handle_event("select_method", %{"method" => method, "arity" => arity} = _params, socket) do
    State.select_method(method, arity)
    {:noreply, assign(socket, state: State.get())}
  end
end
