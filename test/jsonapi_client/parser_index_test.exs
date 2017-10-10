defmodule ParserIndexTest do
  use ExUnit.Case
  doctest JsonApiClient.Parser, import: true

  alias JsonApiClient.{Document, Resource, Parser, JsonApiProtocol, Links}

  @protocol JsonApiProtocol.document_object()

  describe "parse()" do
    test "returns an error when mandatory fileds are missing" do
      assert {:error, _} = Parser.parse(%{}, @protocol)
    end

    test "Resource Object: when data does not contain required fields" do
      document_json = %{
        "data" => [%{
          "type" => "people"
        }]
      }
      assert {:error, "A 'data' MUST contain the following members: type, id"} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: when data contains required fields" do
      document_json = %{
        "data" => [%{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people"
        }]
      }
      assert {:ok, %Document{data: [%Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people"}]
      }} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: when data object is an array" do
      document_json = %{
        "data" => [
        %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people"
        },
        %{
          "id" => "10c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people"
        }]
      }
      assert {:ok, %Document{data: [
        %Resource{
          id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          type: "people"},
        %Resource{
          id: "10c4ca5a-beda-484e-bcd9-77b378aa48f3",
          type: "people"}
        ]
      }} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: when data contains attributes field" do
      document_json = %{
        "data" => [%{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "attributes" => %{
            "first_name" => "John",
            "last_name" => "Doe"
          }
        }]
      }

      assert {:ok, %Document{data: [%Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        attributes: %{
          "first_name" => "John",
          "last_name" => "Doe"
        }
      }]}} = Parser.parse(document_json, @protocol)
    end

    test "Pagination Link: supports self, first, prev, next and last" do
      document_json = %{
        "data" => [],
        "links" => %{
          "self" => "http://example.com/articles?page[number]=3&page[size]=1",
          "first" => "http://example.com/articles?page[number]=1&page[size]=1",
          "prev" => "http://example.com/articles?page[number]=2&page[size]=1",
          "next" => "http://example.com/articles?page[number]=4&page[size]=1",
          "last" => "http://example.com/articles?page[number]=13&page[size]=1"
        }
      }

      assert {:ok, %Document{
        links: %Links{
          self: "http://example.com/articles?page[number]=3&page[size]=1",
          first: "http://example.com/articles?page[number]=1&page[size]=1",
          prev: "http://example.com/articles?page[number]=2&page[size]=1",
          next: "http://example.com/articles?page[number]=4&page[size]=1",
          last: "http://example.com/articles?page[number]=13&page[size]=1"
        }
      }} = Parser.parse(document_json, @protocol)
    end
  end
end