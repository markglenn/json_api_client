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
  @succses_response %Response{
    doc: Poison.encode!(@resource_doc),
    status: 200,
    headers: [{:foo, :bar}],
    attributes: %{stats: %{time: %{action: 10}}}
  }
  @succses_result {:ok, @succses_response}

  @error %RequestError{original_error: "unknown"}

  test "when the doc is OK" do
    assert {:ok, %Response{
      doc: doc,
      status: 200,
      headers: [foo: :bar],
      attributes: %{stats: %{time: %{action: 10, parse_document: time}}}
      }
    } = DocumentParser.call(@request, fn  request ->
      assert request == @request
      @succses_result
    end, %{})

    assert @resource_doc == doc
    assert is_number time
  end

  test "when the next Middleware response is error" do
    originan_error = %RequestError{}
    assert {
      :error,
      %RequestError{
        original_error: "unknown",
        attributes: %{stats: %{time: %{parse_document: time}}}
      }
    } = DocumentParser.call(@request, fn _request -> {:error, @error} end, %{})

    assert is_number time
  end

  test "when a response body is empty" do
    assert {:ok, %Response{
      doc: nil,
      status: 200,
      headers: [foo: :bar],
      attributes: %{stats: %{time: %{action: 10, parse_document: time}}}
    }} = DocumentParser.call(@request, fn _request -> {:ok, %{@succses_response | doc: ""}} end, %{})

    assert is_number time
  end

  test "when a response cannot be parsed" do
    assert {:error, %RequestError{
      original_error: _,
      message: message,
      attributes: %{stats: %{time: %{action: 10, parse_document: time}}}
    }} = DocumentParser.call(@request, fn _request -> {:ok, %{@succses_response | doc: "invalid"}} end, %{})

    assert message =~ "Error Parsing JSON API Document"
    assert is_number time
  end
end