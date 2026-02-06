defmodule FunctionsTest do
  use ExUnit.Case

  alias Iris.Entity.{Module, Module.Method, Module.Method.Call}
  alias Iris.Functions

  defp test_expanded_functions() do
    [
      {"assign_in_out_calls", "4"},
      {"-assign_in_out_calls/4-fun-2-", "3"},
      {"-assign_in_out_calls/4-fun-1-", "3"},
      {"-assign_in_out_calls/4-fun-0-", "2"}
    ]
    |> Enum.map(fn {name, arity} ->
      %Method{
        name: name,
        arity: arity,
        module: "TestModule"
      }
    end)
  end

  defp test_functions_with_call_instructions(functions) do
    for {%Method{} = fun, idx} <- Enum.with_index(functions) do
      %Method{
        fun
        | call_instructions: [
            %Call{
              method: %Method{
                name: "DummyMethod#{idx}",
                arity: "#{idx}",
                module: "OtherTestModule"
              }
            }
          ]
      }
    end
  end

  test "filters auto generated functions correctly" do
    f = test_expanded_functions()

    assert [
             %Method{name: "assign_in_out_calls", arity: "4", module: "TestModule"}
           ] == Functions.filter_auto_generated(f)
  end

  test "condenses functions correctly" do
    f = test_expanded_functions() |> test_functions_with_call_instructions()

    condensed = Functions.condense_functions(f)
    # checking there is only 1 condensed function and assigning it to variable c
    assert [c] = condensed
    assert length(c.call_instructions) == 4

    # checking all call instructions are added to the original one correctly
    assert [
             {"DummyMethod0", "0", "OtherTestModule"},
             {"DummyMethod1", "1", "OtherTestModule"},
             {"DummyMethod2", "2", "OtherTestModule"},
             {"DummyMethod3", "3", "OtherTestModule"}
           ] ==
             c.call_instructions
             |> Enum.map(fn call = %Call{} ->
               {call.method.name, call.method.arity, call.method.module}
             end) |> Enum.sort()
  end
end
