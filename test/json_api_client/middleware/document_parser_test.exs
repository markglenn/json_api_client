defmodule JsonApiClient.Middleware.DocumentParserTest do
  use ExUnit.Case
  doctest JsonApiClient.Middleware.DocumentParser, import: true

  alias JsonApiClient.{Response, RequestError}
  alias JsonApiClient.Middleware.DocumentParser

  @resource_doc %JsonApiClient.Document{
    links: %JsonApiClient.Links{
      self: "http://example.com/articles/1"
    },
    data: %JsonApiClient.Resource{
      type: "articles",
      id: "1",
      attributes: %{
        "title" => "JSON API paints my bikeshed!"
      },
      relationships: %{
        "author" => %JsonApiClient.Relationship{
          links: %JsonApiClient.Links{
            related: "http://example.com/articles/1/author"
          }
        }
      }
    }
  }

  @request %{path: "foo"}
  @succses_response %{body: Poison.encode!(@resource_doc), status_code: 200, headers: [{:foo, :bar}]}
  @instrumentation %{time: %{action: 10}}
  @succses_result {:ok, @succses_response, @instrumentation}

  @error %{reason: "unknown"}

  test "when the doc is OK" do
    assert {
      :ok,
      %Response{doc: @resource_doc, status: 200, headers: [{:foo, :bar}]},
      %{time: %{action: 10, parse_document: time}}
    } = DocumentParser.call(@request, fn  request ->
      assert request == @request
      @succses_result
    end, %{})

    assert is_number time
  end

  test "when the next Middleware response is error" do
    assert {
      :error,
      %RequestError{original_error: @error, message: "Error completing HTTP request: #{@error.reason}"},
      %{time: %{action: 10, parse_document: 0}}
    } == DocumentParser.call(@request, fn _request -> {:error, @error, @instrumentation} end, %{})
  end

  test "when a response body is empty" do
    assert {
     :ok,
     %Response{doc: nil, status: 200, headers: []},
     %{time: %{action: 10, parse_document: 0}}
    } == DocumentParser.call(@request, fn _request -> {:ok, %{body: "", status_code: 200, headers: []}, @instrumentation} end, %{})
  end

  test "when a response cannot be parsed" do
    assert {
     :error,
     %RequestError{original_error: _, message: message},
     %{time: %{action: 10, parse_document: time}}
    } = DocumentParser.call(@request, fn _request -> {:ok, %{body: "invalid", status_code: 200, headers: []}, @instrumentation} end, %{})

    assert message =~ "Error Parsing JSON API Document"
    assert is_number time
  end
end