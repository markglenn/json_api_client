defmodule ParserShowTest do
  use ExUnit.Case
  doctest JsonApiClient.Parser, import: true

  alias JsonApiClient.{Document, Resource, Links, Parser, JsonApiProtocol, Relationship, ResourceIdentifier}

  @protocol JsonApiProtocol.document_object()

  describe "parse()" do
    test "returns an error when mandatory fileds are missing" do
      assert {:error, _} = Parser.parse(%{}, @protocol)
    end

    test "Resource Object: when data does not contain required fields" do
      document_json = %{
        "data" => %{
          "type" => "people"
        }
      }
      assert {:error, "A 'data' MUST contain the following members: type, id"} = Parser.parse(document_json, @protocol)
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
          "first_name" => "John",
          "last_name" => "Doe"
        }
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: when it is not an object" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => "foo"
        }
      }

      assert {:error, "The field 'relationships' must be an object."} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: when mandatory fields are missing" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
            }
          }
        }
      }

      assert {:error, "A 'author' MUST contain at least one of the following members: links, data, meta"} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: supports links and meta" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
              "links" => %{
                "self" => "http://example.com/articles/1/relationships/author",
                "related" => "http://example.com/articles/1/author"
              },
              "meta" => %{
                 "copyright" => "Copyright 2015 Example Corp."
              }
            }
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        relationships: %{
          "author" => %Relationship{
            links: %Links{
              self: "http://example.com/articles/1/relationships/author",
              related: "http://example.com/articles/1/author"
            },
            meta: %{
               "copyright" => "Copyright 2015 Example Corp."
            }
          }
        },
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: support Resource Identifier as a single object" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
              "data" => %{
                "type" => "people",
                "id" => "9",
                "meta" => %{"copyright" => "Copyright 2015 Example Corp."} }
            }
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        relationships: %{
          "author" => %Relationship{
            data: %ResourceIdentifier{
               id: "9",
               type: "people",
               meta: %{
                 "copyright" => "Copyright 2015 Example Corp."
               }
            }
          }
        },
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: support Resource Identifier as an array" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
              "data" => [%{
                "type" => "people",
                "id" => "9",
                "meta" => %{"copyright" => "Copyright 2015 Example Corp."}
              }]
            }
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        relationships: %{
          "author" => %Relationship{
            data: [%ResourceIdentifier{
               id: "9",
               type: "people",
               meta: %{
                 "copyright" => "Copyright 2015 Example Corp."
               }
            }]
          }
        },
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: support Resource Identifier as an empty array" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
              "data" => []
            }
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        relationships: %{
          "author" => %Relationship{
            data: []
          }
        },
      }}} = Parser.parse(document_json, @protocol)
    end

    test "Resource Object: Relationships Object: support Resource Identifier as nil" do
      document_json = %{
        "data" => %{
          "id" => "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
          "type" => "people",
          "relationships" => %{
            "author" => %{
              "data" => nil
            }
          }
        }
      }

      assert {:ok, %Document{data: %Resource{
        id: "91c4ca5a-beda-484e-bcd9-77b378aa48f3",
        type: "people",
        relationships: %{
          "author" => %Relationship{
            data: nil
          }
        },
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