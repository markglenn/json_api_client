defmodule Decisiv.ApiClientTest do
  use ExUnit.Case
  doctest Decisiv.ApiClient

  import Decisiv.ApiClient
  alias Decisiv.ApiClient.{Links, Relationship, Resource, Response}

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  describe ".request" do
    test "get a resource", context do
      single_resource_doc = %{
        links: %{
          self: "http://example.com/articles/1"
        },
        data: %{
          type: "articles",
          id: "1",
          attributes: %{
            title: "JSON API paints my bikeshed!"
          },
          relationships: %{
            author: %{
              links: %{
                related: "http://example.com/articles/1/author"
              }
            }
          }
        }
      }
      Bypass.expect context.bypass, "GET", "/articles/123", fn conn ->
        assert_has_json_api_headers(conn)
        Plug.Conn.resp(conn, 200, Poison.encode! single_resource_doc)
      end

      assert {:ok, single_resource_doc} == request(context.url <> "/articles")
      |> id("123")
      |> method(:get)
      |> execute

      assert {:ok, single_resource_doc} == request(context.url <> "/articles")
      |> execute(method: :get, id: "123") # exec takes a keyword list that maps to helpers

      assert {:ok, single_resource_doc} == request(context.url <> "/articles")
      |> fetch(id: "123") # fetch(list) is the same as exec([method: :get] ++ list)

      assert {:ok, single_resource_doc} == request(context.url <> "/articles")
      |> id("123")
      |> fetch
    end

    @resource_list_json """ 
    {
      "links": {
	"self": "http://example.com/articles"
      },
      "data": [{
	"type": "articles",
	"id": "1",
	"attributes": {
	  "title": "JSON API paints my bikeshed!"
	}
      }, {
	"type": "articles",
	"id": "2",
	"attributes": {
	  "title": "Rails is Omakase"
	}
      }]
    }
    """

    @create_resource_paylod """
    {
      "data": {
        "type": "photos",
        "attributes": {
          "title": "Ember Hamster",
          "src": "http://example.com/images/productivity.png"
        }
      }
    }
    """
    @create_resource_response """
    {
      "data": {
        "type": "photos",
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "attributes": {
          "title": "Ember Hamster",
          "src": "http://example.com/images/productivity.png"
        },
        "links": {
          "self": "http://example.com/photos/550e8400-e29b-41d4-a716-446655440000"
        }
      }
    }
    """

    def assert_has_json_api_headers(conn) do
      headers = for {name, value} <- conn.req_headers, do: {String.to_atom(name), value}

      assert Keyword.get(headers, :accept) == "application/vnd.api+json"
      assert Keyword.get(headers, :"content-type") == "application/vnd.api+json"
      assert Keyword.get(headers, :"user-agent") |> String.starts_with?("ExApiClient")
    end
  end
end
