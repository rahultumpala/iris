defmodule IrisDocTest do
  use ExUnit.Case
  doctest IrisDoc

  defmodule Test do
    use IrisDoc

    def public_fn() do
      "This is a public function."
    end

    @idoc ~S"Private function with docs written using @idoc."
    defp private_fn() do
      "This is a private function."
    end

    @idoc ~S"""
      Private function docs with spaces and newlines.
    """
    defp private_fn_with_spaces_and_newlines() do
      "This is a private function without iris doc."
    end

    @idoc "Works alongside spec()."
    @spec private_fn_with_spec() :: atom()
    defp private_fn_with_spec() do
      :ok
    end
  end

  test "compiles correctly" do
    assert Test.public_fn() == "This is a public function."
  end

  test "exposes __idocs__ function" do
    functions = Test.__info__(:functions)
    assert {:__idocs__, 0} in functions
  end

  test "generates docs" do
    docs = Test.__idocs__()
    assert length(docs) > 0
  end

  test "test doc without spaces" do
    docs = Test.__idocs__()
    doc = docs |> Enum.filter(fn {name, _arity, _doc} -> name == :private_fn end)
    assert doc == [{:private_fn, 0, "Private function with docs written using @idoc."}]
  end

  test "test doc with spaces and newline" do
    docs = Test.__idocs__()

    doc =
      docs
      |> Enum.filter(fn {name, _arity, _doc} -> name == :private_fn_with_spaces_and_newlines end)

    assert doc == [
             {:private_fn_with_spaces_and_newlines, 0,
              "  Private function docs with spaces and newlines.\n"}
           ]
  end

  test "works alongside spec()" do
    docs = Test.__idocs__()

    doc =
      docs
      |> Enum.filter(fn {name, _arity, _doc} -> name == :private_fn_with_spec end)

    assert doc == [
             {:private_fn_with_spec, 0, "Works alongside spec()."}
           ]
  end

  test "raises compile error when orphan attribute is present" do
    test_mod =
      quote do
        defmodule TestMod do
          use IrisDoc
          @idoc "This is an orphan attribute with no private function defined after it."
        end
      end

    assert_raise CompileError,
                 ~r/.* orphan @idoc attribute found in .*, no private function followed it./,
                 fn ->
                   Module.create(TestMod, test_mod, Macro.Env.location(__ENV__))
                 end
  end

  test "raises compile error when @idoc is used before a non-private function" do
    test_mod =
      quote do
        defmodule TestMod do
          use IrisDoc

          @idoc "Using it before a public function declaration"
          def public_fn do
            "Nothing."
          end
        end
      end

    assert_raise CompileError,
                 ~r/.* @idoc supports only private functions and macros defined in the module. Using @idoc before .* is not supported./,
                 fn ->
                   Module.create(TestMod, test_mod, Macro.Env.location(__ENV__))
                 end
  end

  test "works with private macros" do
    test_mod =
      quote do
        defmodule TestMod do
          use IrisDoc

          @idoc "Using it before a private macro declaration"
          defmacrop private_macro do
            "Nothing."
          end
        end
      end

    Module.create(TestMod, test_mod, Macro.Env.location(__ENV__))
    assert true
  end
end
