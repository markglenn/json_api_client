defmodule TestMiddleware do
  def call(_,_,_), do: nil
end

defmodule JsonApiClient.Middleware.StatsTrackerTest do
  use ExUnit.Case, async: true
  doctest JsonApiClient.Middleware.StatsTracker, import: true
  
  alias JsonApiClient.Middleware.StatsTracker
  alias JsonApiClient.Response

  @request %{url: "http://example.com"}
  @response {:ok, %Response{doc: "the doc"}}

  test "adds timer stats to the response" do
    assert {:ok, response} = StatsTracker.call(@request, fn _ -> @response end, :some_name)

    assert %{
      doc: "the doc",
      attributes: %{stats: %{timers: [some_name: ms]}}
    } = response

    assert is_number ms
  end
end
