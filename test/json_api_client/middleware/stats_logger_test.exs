defmodule JsonApiClient.Middleware.StatsLoggerTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  doctest JsonApiClient.Middleware.StatsLogger, import: true
  
  alias JsonApiClient.Middleware.StatsLogger
  alias JsonApiClient.Response

  @request %{url: "http://example.com"}

  test "logs stats from the response" do
    response = %Response{
      attributes: %{
        stats: %{ 
          timers: [
            {:"Elixir.JsonApiClient.Middleware.TestMiddleware1", 30},
            {:"Elixir.JsonApiClient.Middleware.TestMiddleware2", 20},
            {:"Elixir.JsonApiClient.Middleware.TestMiddleware3", 15},
          ]
        }
      }
    }
    next = fn _ -> {:ok, response} end

    log = capture_log fn -> 
      assert {:ok, response} == StatsLogger.call(@request, next, log_level: :info)
    end

    assert log =~ ~r/total_ms=\d+(\.\d+)?/
    assert log =~ "test_middleware1_ms=10"
    assert log =~ "test_middleware2_ms=5"
    assert log =~ "test_middleware3_ms=15"
  end

  test "logs the url" do
    log = capture_log fn -> 
      StatsLogger.call(@request, fn _ -> {:ok, %Response{}} end, [log_level: :info])
    end

    assert log =~ "url=#{@request.url}"
  end
end
