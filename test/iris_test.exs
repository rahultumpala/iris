defmodule IrisTest do
  use ExUnit.Case
  doctest Iris

  test "greets the world" do
    assert Iris.hello() == :world
  end
end
