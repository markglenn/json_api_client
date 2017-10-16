defmodule JsonApiClient.HTTPClient.HTTPoisonTest do
  use ExUnit.Case
  doctest JsonApiClient.HTTPClient.HTTPoison, import: true

  alias JsonApiClient.HTTPClient.HTTPoison
  alias JsonApiClient.{Response}

  setup do
    bypass  = Bypass.open
    headers = [{"Accept", "application/vnd.api+json"}, {"Content-Type", "application/vnd.api+json"}]
    options = [{:timeout, 500}, {:recv_timeout, 500}]

    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}", headers: headers, options: options}
  end

  test "includes status and headers from the HTTP response", context do
    Bypass.expect context.bypass, "GET", "/articles/123", fn conn ->
      conn
      |> Plug.Conn.resp(200, "")
      |> Plug.Conn.put_resp_header("X-Test-Header", "42")
    end

    {:ok, response} = HTTPoison.request(:get, context.url <> "/articles/123", "", context.headers, context.options)

    assert response.status == 200
    assert Enum.member?(response.headers, {"X-Test-Header", "42"})
  end

  test "get a resource", context do
    doc = single_resource_doc()
    Bypass.expect context.bypass, "GET", "/articles/123", fn conn ->
      Plug.Conn.resp(conn, 200, Poison.encode! doc)
    end

    assert {:ok, %Response{status: 200, doc: ^doc}} = HTTPoison.request(:get, context.url <> "/articles/123", "", context.headers, context.options)
  end

  def single_resource_doc do
    %JsonApiClient.Document{
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
  end
end