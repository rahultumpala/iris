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
      <span :for={method <- @module.exports} class="w-5 max-w-[5vh]">
        {render_method_block(assigns, method)}
      </span>
    </div>
    """
  end

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity.Module, required: true

  def code(assigns) do
    ~H"""
    <div class={"basis-full visibility=#{@show}"}></div>
    """
  end

  defp render_method_block(assigns, %Method{} = method) do
    ~H"""
    <div class="flex flex-row border border-gray-200 shadow-2xs justify-around">
      <div class="p-2">
        <div class="flex flex-row mx-2">
          <p class="text-lg font-semibold text-gray-800">{method.name}</p>
          <p class="text-lg text-gray-500">/{method.arity}</p>
        </div>
      </div>
      <div class="font-semibold mx-2">
        BIF
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
      <div class="flex border-b justify-around gap-5 border-zinc-100 py-3 text-sm">
        <p class="text-lg text-white rounded-sm px-4 font-medium leading-6">
          Iris
        </p>
        <a href="https://github.com/rahultumpala/iris" class="font-medium text-white">
          GitHub
        </a>
      </div>
    </header>
    """
  end
end
