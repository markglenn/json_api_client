defmodule ParserShowTest do
  use ExUnit.Case
  doctest JsonApiClient.Parsers.Parser, import: true

  alias JsonApiClient.{Document, JsonApi, Resource, PaginationLinks, Links}
  alias JsonApiClient.Parsers.{Parser, JsonApiProtocol}

  @protocol JsonApiProtocol.show_document_object()

  describe "parse()" do
    test "returns an error when mandatories fileds are missing" do
      assert {:error, _} = Parser.parse(%{}, @protocol)
    end

    test "Resource Object: when data is an array" do
      assert {:error, "The filed 'data' cannot be an array."} = Parser.parse(%{"data" => [%{}]}, @protocol)
    end

    test "Resource Object: when data does not contain required fields" do
      document_json = %{
        "data" => %{
          "type" => "people"
        }
      }
      assert {:error, "A 'data' MUST contain following members: type, id"} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: when data contains required fields" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people"
        }
      }
      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people"}
      }} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: when data contains attributes field" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "attributes" => %{
            "first_name" => "John",
            "last_name" => "Doe"
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        attributes: %{
          first_name: "John",
          last_name: "Doe"
        }
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Links: supports self and related" do
      document_json = %{
        "meta" => %{},
        "links" => %{
          "self" => "http://example.com/articles?page[number]=3&page[size]=1",
          "related" => "http://example.com/articles?page[number]=1&page[size]=1"
        }
      }

      assert {:ok, %Document{
        links: %Links{
          self: "http://example.com/articles?page[number]=3&page[size]=1",
          related: "http://example.com/articles?page[number]=1&page[size]=1"
        }
      }} = Parser.parse(document_json, @protocol)
    end
  end
end