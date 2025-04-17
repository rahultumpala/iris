defmodule IrisWeb.IrisComponents do
  use Phoenix.Component
  use Gettext, backend: IrisWeb.Gettext

  alias Iris.Entity.Module.Method

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity.Module, required: true
  attr :class, :string, default: nil

  def exports(assigns) do
    ~H"""
    <div class={[
      "exports visibility=#{@show}",
      @class
    ]}>
      <span
        :for={method <- @module.methods}
        class="py-1 block hover:bg-zinc-100 hover:cursor-pointer"
        phx-click="select_method"
        phx-value-method={method.name}
        phx-value-arity={method.arity}
      >
        {render_method_block(assigns, method)}
      </span>
    </div>
    """
  end

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity.Module, required: true
  attr :method, Iris.Entity.Module.Method

  def code(assigns) do
    ~H"""
    <div class={"visibility=#{@show} flex flex-col"}>
      <%= if @method == nil do %>
        <h3 class="p-5">
          No methods defined in module
        </h3>
      <% else %>
        <div class="flex flex-row p-5">
          <div class="flex flex-row">
            <div class="text-lg m-1 font-semibold">Name:</div>
            <div class="val m-1 text-md place-content-center">{@method.name}</div>
          </div>
          <div class="flex flex-row">
            <div class="text-lg m-1 font-semibold">Arity:</div>
            <div class="text-md m-1 place-content-center">{@method.arity}</div>
          </div>
          <div class="flex flex-row">
            <div class="text-lg m-1 font-semibold">Type:</div>
            <div class="val m-1 text-md place-content-center">{@method.type}</div>
          </div>
        </div>
        <div class="bg-zinc-50 basis-full p-5 whitespace-pre">
          <p>{@method.code}</p>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_method_block(assigns, %Method{} = method) do
    assigns = assign(assigns, :method, method)

    ~H"""
    <div class="flex flex-row items-center justify-between">
      <div class="p-2">
        <div class="flex flex-row mr-2">
          <p class="text-md">{@method.name}</p>
          <p class="text-md">/{@method.arity}</p>
        </div>
      </div>
      <div class="px-2 bg-zinc-50 text-sm text-zinc-500 mr-1">
        <p>{method.html_type_text}</p>
      </div>
    </div>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "rounded-lg hover:bg-zinc-100 p-3",
        "w-full text-left",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def card_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "bg-violet-800 text-white hover:bg-violet-800 p-1",
        "font-semibold",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  attr :class, :string, default: nil

  slot :inner_block, required: true

  def sidebar(assigns) do
    ~H"""
    <div class={[
      "flex flex-col h-screen",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def header(assigns) do
    ~H"""
    <header class="bg-indigo-800 rounded-rt-md">
      <div class="flex border-b justify-around border-zinc-100 py-3 text-lg">
        <p class="place-content-center text-white rounded-sm px-4">
          Iris
        </p>
        <a href="https://github.com/rahultumpala/iris" class="text-white">
          <img class="h-[2.5vh] w-full" src="images/github-mark-white.svg" />
        </a>
      </div>
    </header>
    """
  end
end
