defmodule TestMiddleware do
  def call(_,_,_), do: nil
end

defmodule JsonApiClient.Middleware.StatsTrackerTest do
  use ExUnit.Case, async: true
  import Mock
  doctest JsonApiClient.Middleware.StatsTracker, import: true
  
  alias JsonApiClient.Middleware.StatsTracker
  alias JsonApiClient.Response

  @request %{url: "http://example.com"}
  @response {:ok, %Response{}}

  test "adds timer stats to the response" do
    test_middleware_options = {:test_middleware_option, 1}
    options = [wrap: {TestMiddleware, test_middleware_options}]
    next = fn _ -> @response end

    with_mock TestMiddleware, [call: fn (_, _, _) -> @response end] do
      returned = StatsTracker.call(@request, next, options)

      assert called TestMiddleware.call(@request, next, test_middleware_options)
      assert {:ok, %{attributes: %{stats: %{timers: [{TestMiddleware, ms}]}}}} = returned
      assert is_number ms
    end
  end
end
