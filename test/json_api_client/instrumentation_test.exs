defmodule JsonApiClient.InstrumentationTest do
  use ExUnit.Case
  doctest JsonApiClient.Instrumentation, import: true

  import ExUnit.CaptureLog
  alias JsonApiClient.Instrumentation

  describe ".track_stats" do
    test "returns a result and stats" do
      assert{:foo, :bar, %{time: %{action: time}}} =
        Instrumentation.track_stats(:action, fn -> {:foo, :bar} end, %{})

       assert is_number time
    end

    test "merges instrumentations" do
      assert {:foo, :bar, %{time: %{action: time, action1: 10}}} =
        Instrumentation.track_stats(:action, fn -> {:foo, :bar} end, %{time: %{action1: 10}})

       assert is_number time
    end

    test "when no function is provided it returns a result and stats" do
      assert{:foo, :bar, %{time: %{action: 0}}} =  Instrumentation.track_stats( :action, {:foo, :bar}, %{})
    end

    test "when no function is provided it merges stats" do
      assert {:foo, :bar, %{time: %{action: 0, action1: 10}}} =
        Instrumentation.track_stats( :action, {:foo, :bar}, %{time: %{action1: 10}})
    end
  end

  describe ".log" do
    test "when logging is enabled" do
      stats = %{time: %{action: 10}}
      log   = capture_log(fn -> Instrumentation.log(stats, :warn) end)
      assert log  =~ "time.action=10"
    end

    test "when logging is disabled" do
      stats = %{time: %{action: 10}}
      assert capture_log(fn -> Instrumentation.log(stats, nil) end) == ""
    end
  end
end