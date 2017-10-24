defmodule JsonApiClient.InstrumentationTest do
  use ExUnit.Case
  doctest JsonApiClient.Instrumentation, import: true

  import ExUnit.CaptureLog
  alias JsonApiClient.Instrumentation
  alias JsonApiClient.Response

  describe ".track_stats" do
    test "returns a result and stats" do
      assert {:ok, %Response{
        attributes: %{stats: %{time: %{action: time}}}
      }} = Instrumentation.track_stats(:action, fn -> {:ok, %Response{}} end)

      assert is_number time
    end

    test "merges instrumentations" do
      assert {:ok, %Response{
        attributes: %{stats: %{time: %{action: time, action1: 10}}}
      }} = Instrumentation.track_stats(:action, fn -> {:ok, response_with_stats()} end)

       assert is_number time
    end

    test "when no function is provided it returns a result and stats" do
      assert {:ok, %Response{
        attributes: %{stats: %{time: %{action: 0}}}
      }} = Instrumentation.track_stats(:action, {:ok, %Response{}})
    end

    test "when no function is provided it merges stats" do
      assert {:ok, %Response{
        attributes: %{stats: %{time: %{action: 0, action1: 10}}}
      }} = Instrumentation.track_stats(:action, {:ok, response_with_stats()} )
    end
  end

  defp response_with_stats do
    %Response{attributes: %{stats: %{time: %{action1: 10}}}}
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