defmodule JsonApiClient.HTTPClient.HTTPoisonTest do
  use ExUnit.Case
  doctest JsonApiClient.HTTPClient.HTTPoison, import: true

  import Mock

  alias HTTPoison, as: UnderlyingClient
  alias JsonApiClient.HTTPClient.HTTPoison

  @response_body "body"

  setup do
    bypass  = Bypass.open
    headers = [{"Accept", "application/vnd.api+json"}, {"Content-Type", "application/vnd.api+json"}]
    options = [{:timeout, 500}, {:recv_timeout, 500}]

    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}/articles", headers: headers, options: options, body: ""}
  end

  test "uses HTTPoison as underlying http client", context do
    with_mock UnderlyingClient, [], [request: fn(method, url, body, headers, http_options) ->
      assert method == :get
      assert url == context.url
      assert body == context.body
      assert headers == context.headers
      assert http_options == context.options

      {:ok, %{status_code: 500, headers: [], body: ""}}
    end] do
      request(context)
    end
  end

  test "includes status_code from the HTTP response", context do
    Bypass.expect context.bypass, "GET", "/articles", fn conn ->
      conn
      |> Plug.Conn.resp(200, "")
    end

    {:ok, response} = request(context)

    assert response.status_code == 200
  end

  test "includes headers from the HTTP response", context do
    Bypass.expect context.bypass, "GET", "/articles", fn conn ->
      conn
      |> Plug.Conn.resp(200, "")
      |> Plug.Conn.put_resp_header("X-Test-Header", "42")
    end

    {:ok, response} = request(context)

    assert Enum.member?(response.headers, {"X-Test-Header", "42"})
  end

  test "includes body from the HTTP response", context do
    Bypass.expect context.bypass, "GET", "/articles", fn conn ->
      Plug.Conn.resp(conn, 200, @response_body)
    end

    {:ok, response} = request(context)

    assert response.body == @response_body
  end

  defp request(context) do
    HTTPoison.request(:get, context.url , context.body, context.headers, context.options)
  end
end