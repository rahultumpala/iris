defmodule IrisWeb.IrisComponents do
  use Phoenix.Component
  use Gettext, backend: IrisWeb.Gettext

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity, required: true

  def exports(assigns) do
    ~H"""
    <div class={"mt-3 pt-3 basis-full flex flex-row max-h-[80vh] max-w-screen flex-row flex-wrap visibility=#{@show}"}>
      <span :for={method <- @module.exports} class="flex flex-row m-2">
        {render_method_block(assigns, method)}
      </span>
    </div>
    """
  end

  attr :show, :string, default: "hidden"
  attr :module, Iris.Entity, required: true

  def code(assigns) do
    ~H"""
    <div class={"basis-full visibility=#{@show}"}></div>
    """
  end

  defp render_method_block(assigns, %Iris.Entity.Method{} = method) do
    ~H"""
    <div class="flex flex-col bg-white border border-gray-200 shadow-2xs rounded-xl">
      <div class="bg-gray-100 border-b border-gray-200 rounded-t-xl py-1 px-4">
        <p class="mt-1 text-sm text-gray-500 dark:text-neutral-500">
          Built-in function
        </p>
      </div>
      <div class="p-4 md:p-5">
        <h3 class="text-lg font-bold text-gray-800 dark:text-white">
          {method.name}/{method.arity}
        </h3>
        <p class="mt-2 text-gray-500 dark:text-neutral-400">
          maybe show ex_docs doc here
        </p>
        <a
          class="mt-3 inline-flex items-center gap-x-1 text-sm font-semibold rounded-lg border border-transparent text-blue-600 decoration-2 hover:text-blue-700 hover:underline focus:underline focus:outline-hidden focus:text-blue-700 disabled:opacity-50 disabled:pointer-events-none"
          href="#"
        >
          View descendants
          <svg
            class="shrink-0 size-4"
            xmlns="http://www.w3.org/2000/svg"
            width="24"
            height="24"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          >
            <path d="m9 18 6-6-6-6"></path>
          </svg>
        </a>
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
end
