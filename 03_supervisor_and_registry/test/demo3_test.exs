defmodule Demo3Test do
  use ExUnit.Case
  doctest Demo3

  test "greets the world" do
    assert Demo3.hello() == :world
  end
end
