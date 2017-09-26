defmodule Decisiv.ApiClientTest do
  use ExUnit.Case
  doctest Decisiv.ApiClient

  alias Decisiv.ApiClient

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  describe ".request" do
    @single_resource_json """
    {
      "links": {
        "self": "http://example.com/articles/1"
      },
      "data": {
        "type": "articles",
        "id": "1",
        "attributes": {
          "title": "JSON API paints my bikeshed!"
        },
        "relationships": {
          "author": {
            "links": {
              "related": "http://example.com/articles/1/author"
            }
          }
        }
      }
    }
    """

    test "get a resource", context do
      path = "/articles/123"
      Bypass.expect_once context.bypass, "GET", path, fn conn ->
        assert_has_json_api_headers(conn)
        Plug.Conn.resp(conn, 200, @single_resource_json)
      end
      {:ok, resp} = ApiClient.request(:get, context.url <> path)
      assert Poison.decode!(@single_resource_json) == resp
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

    test "get a resource list with params", context do
      path = "/articles"
      Bypass.expect_once context.bypass, fn conn ->
        assert_has_json_api_headers(conn)
        conn = Plug.Conn.fetch_query_params(conn)
        assert %{
          request_path: ^path,
          method: "GET",
          query_params: %{"sort" => "age", "filter" => %{"foo" => "bar"}},
        } = conn
          
        Plug.Conn.resp(conn, 200, @resource_list_json)
      end

      {:ok, resp} = ApiClient.request(:get, context.url <> path, [
        params: %{sort: "age", filter: %{foo: "bar"}}
      ])
      assert Poison.decode!(@resource_list_json) == resp
    end

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

    test "creates a JSON API resource", context do
      path = "/articles"
      Bypass.expect_once context.bypass, "POST", path, fn conn ->
        assert_has_json_api_headers(conn)
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert JSX.minify(body) == JSX.minify(@create_resource_paylod)

        Plug.Conn.resp(conn, 200, @create_resource_response)
      end
      resource = Poison.decode!(@create_resource_paylod)["data"]
      {:ok, resp} = ApiClient.request(:post, context.url <> path, data: resource) 
      assert Poison.decode!(@create_resource_response) == resp
    end

    def assert_has_json_api_headers(conn) do
      headers = for {name, value} <- conn.req_headers, do: {String.to_atom(name), value}

      assert Keyword.get(headers, :accept) == "application/vnd.api+json"
      assert Keyword.get(headers, :"content-type") == "application/vnd.api+json"
      assert Keyword.get(headers, :"user-agent") |> String.starts_with?("ExApiClient")
    end
  end
end
