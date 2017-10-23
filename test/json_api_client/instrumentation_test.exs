defmodule JsonApiClient.InstrumentationTest do
  use ExUnit.Case
  doctest JsonApiClient.Instrumentation, import: true

  import ExUnit.CaptureLog
  alias JsonApiClient.Instrumentation

  describe ".instrumentation" do
    test "returrns a result and instrumentation" do
      assert{:foo, :bar, %{time: %{action: time}}} =
        Instrumentation.instrumentation(:action, fn -> {:foo, :bar} end, %{})

       assert is_number time
    end

    test "merge instrumentations" do
      assert {:foo, :bar, %{time: %{action: time, action1: 10}}} =
        Instrumentation.instrumentation(:action, fn -> {:foo, :bar} end, %{time: %{action1: 10}})

       assert is_number time
    end
  end

  describe ".add_instrumentation" do
    test "returrns a result and instrumentation" do
      assert{:foo, :bar, %{time: %{action: 2}}} =  Instrumentation.add_instrumentation( {:foo, :bar}, :action, %{}, 2)
    end

    test "merge instrumentations" do
      assert {:foo, :bar, %{time: %{action: 2, action1: 10}}} =
        Instrumentation.add_instrumentation( {:foo, :bar}, :action, %{time: %{action1: 10}}, 2)
    end
  end

  describe ".log" do
    test "when logging is enabled" do
      stats = %{time: %{action: 10}}
      assert capture_log(fn -> Instrumentation.log(stats, :warn) end) =~ Poison.encode!(stats)
    end

    test "when logging is disabled" do
      stats = %{time: %{action: 10}}
      assert capture_log(fn -> Instrumentation.log(stats, nil) end) == ""
    end
  end
end