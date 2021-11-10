defmodule RabbitCodeTest do
  use ExUnit.Case
  doctest RabbitCode

  test "greets the world" do
    assert RabbitCode.hello() == :world
  end
end
