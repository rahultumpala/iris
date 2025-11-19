defmodule IrisDoc do
  defmacro __using__(_) do
    quote do
      # Single value user attribute
      Module.register_attribute(__MODULE__, :idoc, accumulate: false, persist: true)

      # Internal attribute tot track positions
      Module.register_attribute(__MODULE__, :__idoc_line__, accumulate: false)

      # Collected docs
      Module.register_attribute(__MODULE__, :__idocs__, accumulate: true)

      @before_compile {IrisDoc, :before_compile}
      @on_definition {IrisDoc, :on_definition}
    end
  end

  @doc """
  This hook is triggered when a function or macro is defined.
  Uses Pattern matching to execute only when private functions are defined.
  """
  def on_definition(env, kind, name, args, _guards, _body) when kind == :defp do
    module = env.module
    idoc = Module.get_attribute(module, :idoc)
    arity = length(args)

    cond do
      # Checks that idoc isn't nil
      idoc ->
        Module.put_attribute(module, :__idocs__, {name, arity, idoc})
        cleanup_attributes(module)
        :ok

      # Regular function with no doc
      true ->
        :ok
    end
  end

  def on_definition(env, kind, name, args, _guards, _body) do
    pending = is_pending?(env.module)

    if pending do
      raise CompileError,
        file: env.file,
        description:
          "@idoc supports only private functions defined in the module. Using @idoc before `#{kind} #{name}/#{length(args)}` is not supported."
    end

    cleanup_attributes(env.module)
  end

  @doc """
    Verify just before compilation finishes that no orphan @idoc annotations are present in the source code.
    This has to be a macro to ensure the returned AST is added at the end of module definition.
    If this is defined to be a function then the returned AST is not appended and the __idocs__ function cannot be invoked.
  """
  defmacro before_compile(env) do
    pending = is_pending?(env.module)

    if pending do
      raise CompileError,
        file: env.file,
        description:
          "orphan @idoc attribute found in #{env.file}, no private function followed it."
    end

    quote do
      def __idocs__(), do: @__idocs__
    end
  end

  defp cleanup_attributes(module) do
    Module.delete_attribute(module, :idoc)
    Module.delete_attribute(module, :__idoc_pending__)
    Module.delete_attribute(module, :__idoc_line__)
  end

  defp is_pending?(module) do
    Module.get_attribute(module, :idoc) != nil
  end
end
