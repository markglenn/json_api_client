defmodule JsonApiClientTest do
  use ExUnit.Case
  doctest JsonApiClient, import: true

  import Mock
  import JsonApiClient
  import JsonApiClient.Request
  alias JsonApiClient.{Request, Resource, Response, RequestError}
  alias JsonApiClient.HTTPClient.HTTPoison

  setup do
    bypass = Bypass.open

    {:ok, bypass: bypass, url: "http://localhost:#{bypass.port}"}
  end

  test "return HTTP Backend response", context do
    with_mock HTTPoison, [], [request: fn(_, _, _, _, _) -> {:ok, %Response{status: 201, doc: "foo"}} end] do
      assert {:ok, %Response{status: 201, doc: "foo"}} = fetch Request.new(context.url <> "/articles/123")
    end
  end

  test "add json api headers", context do
    with_mock HTTPoison, [], [
      request: fn(_, _, _, headers, _) ->
          assert_has_json_api_headers(headers)
          {:ok, %Response{status: 201}}
        end
      ] do
      fetch Request.new(context.url <> "/articles/123")
    end
  end

  test "set user agent with user suffix", context do
    Mix.Config.persist(json_api_client: [user_agent_suffix: "my_sufix"])
    with_mock HTTPoison, [], [
      request: fn(_, _, _, headers, _) ->
          assert Keyword.get(to_atoms_keys(headers), :"User-Agent") == "json_api_client/" <> Mix.Project.config[:version] <> "/my_sufix"
          {:ok, %Response{status: 201}}
        end
      ] do
      fetch Request.new(context.url <> "/articles/123")
      Mix.Config.persist(json_api_client: [user_agent_suffix: Mix.Project.config[:app]])
    end
  end

  test "get a list of resources", context do
    doc = multiple_resource_doc()
    with_mock HTTPoison, [], [
      request: fn(:get, url, _, headers, options) ->
          assert url == context.url <> "/articles"
          assert_has_json_api_headers(headers)
          assert [
            {"custom1", "1"},
            {"custom2", "2"},
            {"fields[articles]", "title,topic"},
            {"fields[authors]", "first-name,last-name,twitter"},
            {"filter[published]", "true"},
            {"include", "author"},
            {"page[size]", "10"},
            {"page[number]", "1"},
            {"sort", "id"}] == Keyword.get(options, :params)

          {:ok, %Response{status: 200, doc: doc}}
        end
      ] do
      assert {:ok, %Response{status: 200, doc: ^doc}} = Request.new(context.url <> "/articles")
      |> fields(articles: "title,topic", authors: "first-name,last-name,twitter")
      |> include(:author)
      |> sort(:id)
      |> page(size: 10, number: 1)
      |> filter(published: true)
      |> params(custom1: 1, custom2: 2)
      |> fetch
    end
  end

  test "delete a resource", context do
    with_mock HTTPoison, [], [
      request: fn(:delete, url, _, headers, _) ->
          assert url == context.url <> "/articles/123"
          assert_has_json_api_headers(headers)
          {:ok, %Response{status: 204}}
        end
      ] do

      assert {:ok, %Response{status: 204, doc: nil}} = Request.new(context.url <> "/articles")
      |> id("123")
      |> delete
    end
  end

  test "create a resource", context do
    doc = single_resource_doc()
    with_mock HTTPoison, [], [
      request: fn(:post, url, body, headers, _) ->
          assert url == context.url <> "/articles"
          assert_has_json_api_headers(headers)
          assert %{
            "data" => %{
              "type" => "articles",
              "attributes" => %{
                "title" => "JSON API paints my bikeshed!",
              },
            }
          } = Poison.decode! body

          {:ok, %Response{status: 201, doc: doc}}
        end
      ] do

      new_article = %Resource{
        type: "articles",
        attributes: %{
          title: "JSON API paints my bikeshed!",
        }
      }

      assert {:ok, %Response{status: 201, doc: ^doc}} = Request.new(context.url)
      |> resource(new_article)
      |> create
    end
  end

  test "update a resource", context do
    doc = single_resource_doc()
    with_mock HTTPoison, [], [
      request: fn(:patch, url, body, headers, _) ->
          assert url == context.url <> "/articles"
          assert_has_json_api_headers(headers)
          assert %{
            "data" => %{
              "type" => "articles",
              "attributes" => %{
                "title" => "JSON API paints my bikeshed!",
              },
            }
          } = Poison.decode! body

          {:ok, %Response{status: 201, doc: doc}}
        end
      ] do

      new_article = %Resource{
        type: "articles",
        attributes: %{
          title: "JSON API paints my bikeshed!",
        }
      }

      assert {:ok, %Response{status: 201, doc: ^doc}} = Request.new(context.url)
      |> resource(new_article)
      |> update
    end
  end

  describe "Error Contidions" do
    test "HTTP success codes with invalid Documents", context do
      Bypass.expect context.bypass, fn conn ->
        Plug.Conn.resp(conn, 200, "this is not json")
      end

      assert {:error, %JsonApiClient.RequestError{status: 200}} = fetch(Request.new(context.url <> "/"))
    end

    test "HTTP error codes with no content", context do
      Bypass.expect context.bypass, fn conn ->
        Plug.Conn.resp(conn, 422, "")
      end

      assert {:ok, %Response{status: 422, doc: nil}} = fetch(Request.new(context.url <> "/"))
    end

    test "HTTP error codes with valid Documents", context do
      doc = error_doc()
      Bypass.expect context.bypass, fn conn ->
        Plug.Conn.resp(conn, 422, Poison.encode! doc)
      end

      assert {:ok, %Response{status: 422, doc: ^doc}} = fetch(Request.new(context.url <> "/"))
    end

    test "Failed TCP/HTTP connection", context do
      Bypass.down(context.bypass)

      assert {:error, %RequestError{
        original_error: %{reason: :econnrefused},
        status: nil,
      }} = fetch(Request.new(context.url <> "/"))
    end
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

  def multiple_resource_doc do
    %JsonApiClient.Document{
      links: %JsonApiClient.Links{
        self: "http://example.com/articles"
      },
      data: [%JsonApiClient.Resource{
        type: "articles",
        id: "1",
        attributes: %{
          "title" => "JSON API paints my bikeshed!",
          "category" => "json-api",
        },
        relationships: %{
          "author" => %JsonApiClient.Relationship{
            links: %JsonApiClient.Links{
              self: "http://example.com/articles/1/relationships/author",
              related: "http://example.com/articles/1/author"
            },
            data: %JsonApiClient.ResourceIdentifier{ type: "people", id: "9" }
          },
        }
      }, %JsonApiClient.Resource{
        type: "articles",
        id: "2",
        attributes: %{
          "title" => "Rails is Omakase",
          "category" => "rails",
        },
        relationships: %{
          "author" => %JsonApiClient.Relationship{
            links: %JsonApiClient.Links{
              self: "http://example.com/articles/1/relationships/author",
              related: "http://example.com/articles/1/author"
            },
            data: %JsonApiClient.ResourceIdentifier{ type: "people", id: "9" }
          },
        }
      }],
      included: [%JsonApiClient.Resource{
        type: "people",
        id: "9",
        attributes: %{
          "first-name" => "Dan",
          "last-name" => "Gebhardt",
          "twitter" => "dgeb",
        },
        links: %JsonApiClient.Links{
          self: "http://example.com/people/9"
        }
      }]
    }
  end

  describe "dangerous execution functions raise erorrs on error" do
    setup context do
      Bypass.down(context.bypass)
      [request: Request.new(context.url <> "/articles")]
    end

    test "execute!", %{request: req}, do: assert_raise RequestError, fn -> execute! req end
    test "fetch!"  , %{request: req}, do: assert_raise RequestError, fn -> fetch!   req end
    test "update!" , %{request: req}, do: assert_raise RequestError, fn -> update!  req end
    test "create!" , %{request: req}, do: assert_raise RequestError, fn -> create!  req end
    test "delete!" , %{request: req}, do: assert_raise RequestError, fn -> delete!  req end
  end

  describe "dangerous execution functions return Response on success" do
    setup context do
      Bypass.expect context.bypass, fn conn ->
        Plug.Conn.resp(conn, 200, Poison.encode! multiple_resource_doc())
      end
      [request: Request.new(context.url <> "/articles")]
    end

    test "execute!", %{request: req}, do: assert %Response{} = execute! req
    test "fetch!"  , %{request: req}, do: assert %Response{} = fetch!   req
    test "update!" , %{request: req}, do: assert %Response{} = update!  req
    test "create!" , %{request: req}, do: assert %Response{} = create!  req
    test "delete!" , %{request: req}, do: assert %Response{} = delete!  req
  end

  def error_doc do
    %JsonApiClient.Document{
      errors: [
	%JsonApiClient.Error{
	  status: "422",
	  source: %JsonApiClient.ErrorSource{
            pointer: "/data/attributes/first-name"
          },
	  title:  "Invalid Attribute",
	  detail: "First name must contain at least three characters."
	}
      ]
    }
  end

  def to_map(keyword) do
    for [key, val] <- Enum.chunk(keyword, 2), do: {key, val}
  end

  def to_atoms_keys(headers) do
    for {name, value} <- headers, do: {String.to_atom(name), value}
  end

  def assert_has_json_api_headers(headers) do
    headers = to_atoms_keys(headers)
    assert Keyword.get(headers, :"Accept") == "application/vnd.api+json"
    assert Keyword.get(headers, :"Content-Type") == "application/vnd.api+json"
    assert Keyword.get(headers, :"User-Agent") == "json_api_client/" <> Mix.Project.config[:version] <> "/#{Mix.Project.config[:app]}"
  end
end
