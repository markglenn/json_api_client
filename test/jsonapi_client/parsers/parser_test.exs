defmodule ParserTest do
  use ExUnit.Case
  doctest JsonApiClient.Parsers.Parser, import: true

  alias JsonApiClient.{Document, JsonApi, Resource, PaginationLinks}
  alias JsonApiClient.Parsers.{Parser, JsonApiProtocol}

  @protocol JsonApiProtocol.index_document_fields()

  describe "parse()" do
    test "returns an error when mandatories fileds are missing" do
      assert {:error, _} = Parser.parse(%{}, @protocol)
    end

    test "returns a Document" do
      assert {:ok, %Document{}} = Parser.parse(%{"meta" => %{}}, @protocol)
    end

    test "returns an error when a value is an array instead of simple value" do
      document_json = %{
        "meta" => %{},
        "jsonapi" => %{
          "version" => ["2.0"],
          "meta" => %{}
        }
      }
      assert {:error, _} = Parser.parse(document_json, @protocol)
    end

    test "JSON API Object: is added when original data does not have jsonapi attribute" do
      assert {:ok, %Document{jsonapi: %JsonApi{version: "1.0", meta: %{}}}} = Parser.parse(%{"meta" => %{}}, @protocol)
    end

    test "JSON API Object: is added using fields from data jsonapi attribute" do
      document_json = %{
        "meta" => %{},
        "jsonapi" => %{
          "version" => "2.0",
          "meta" => %{}
        }
      }
      assert {:ok, %Document{jsonapi: %JsonApi{version: "2.0", meta: %{}}}} = Parser.parse(document_json, @protocol)
    end

    test "JSON API Object: is added with meta atoms keys to jsonapi field" do
      document_json = %{
        "meta" => %{},
        "jsonapi" => %{
          "version" => "2.0",
          "meta" => %{
            "copyright" => "Copyright 2015 Example Corp."
          }
        }
      }
      assert {:ok,
              %Document{
                jsonapi: %JsonApi{version: "2.0", meta: %{ copyright: "Copyright 2015 Example Corp."}}
              }} = Parser.parse(document_json, @protocol)
    end

    test "JSON API Object: error is reported when meta is not an object" do
      document_json = %{
        "meta" => %{},
        "jsonapi" => %{
          "version" => "2.0",
          "meta" => "foo"
        }
      }
      assert {:error, "The filed 'meta' must be an object."} = Parser.parse(document_json, @protocol)
    end

    test "Meta Object: is added with meta atoms keys to jsonapi field" do
      document_json = %{
        "meta" => %{
          "copyright" => "Copyright 2015 Example Corp."
        }
      }
      assert {:ok,
              %Document{ meta: %{ copyright: "Copyright 2015 Example Corp."}}} = Parser.parse(document_json, @protocol)
    end

    test "Meta Object: error is reported when meta is not an object" do
      document_json = %{
        "meta" => "foo"
      }
      assert {:error, "The filed 'meta' must be an object."} = Parser.parse(document_json, @protocol)
    end

    test "Included Object: error is reported when included is not an array" do
      document_json = %{
        "meta" => %{},
        "included" => %{}
      }
      assert {:error, "The filed 'included' must be an array."} = Parser.parse(document_json, @protocol)
    end

    test "Included Object: when data does not contain required fields" do
      document_json = %{
        "meta" => %{},
        "included" => [%{
          "type" => "people"
        }]
      }
      assert {:error, "A 'included' MUST contain following members: type, id"} = Parser.parse(document_json, @protocol)
    end

    test "Included Object: when data contains required fields" do
      document_json = %{
        "meta" => %{},
        "included" => [%{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people"
        }]
      }
      assert {:ok, %Document{included: [%Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people"}]
      }} = Parser.parse(document_json, @protocol)
    end
  end
end