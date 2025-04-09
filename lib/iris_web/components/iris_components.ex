defmodule IrisWeb.IrisComponents do
  use Phoenix.Component
  use Gettext, backend: IrisWeb.Gettext

  alias Iris.Entity.Module.Method

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity.Module, required: true

  def exports(assigns) do
    ~H"""
    <div class={"mt-3 pt-3 basis-full flex flex-row max-h-[80vh] max-w-screen flex-row flex-wrap visibility=#{@show}"}>
      <span :for={method <- @module.exports} class="m-1">
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
    <div class="flex flex-col bg-white border border-gray-200 shadow-2xs rounded-xl">
      <div class="bg-gray-100 border-b border-gray-200 rounded-t-xl py-1 px-4">
        <p class="mt-1 text-sm text-gray-500 dark:text-neutral-500">
          Built-in function
        </p>
      </div>
      <div class="p-4 md:p-5">
        <div class="flex flex-row">
          <h3 class="text-lg font-bold text-gray-800">{method.name}</h3>
          <h3 class="text-lg font-bold text-gray-500">/{method.arity}</h3>
        </div>
      </div>
      <div class="flex flex-row">
        <.card_button
          class="rounded-bl-lg basis-1/2"
          phx-click="show_doc"
          phx-value-module={method.name}
        >
          Doc
        </.card_button>
        <.card_button
          class="rounded-br-lg basis-1/2"
          phx-click="show_paths"
          phx-value-module={method.name}
        >
          Paths
        </.card_button>
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
        "font-semibold",
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

  attr :heading, :string, required: true
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def sidebar(assigns) do
    ~H"""
    <div class={[
      "flex flex-col h-screen",
      @class
    ]}>
      <h1 class="font-bold text-lg">
        {@heading}
      </h1>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
