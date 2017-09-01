defmodule ExDecisivApiClientTest do
  use ExUnit.Case
  doctest ExDecisivApiClient

  test "greets the world" do
    assert ExDecisivApiClient.hello() == :world
  end
end
