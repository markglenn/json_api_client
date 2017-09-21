defmodule Decisiv.JsonApi.ParserTest do
  use ExUnit.Case

  setup do
    [
      data_response: [
        %{"attributes" =>
          %{"author" => "test author", "body" => "blah",
            "posted_at" => nil,
            "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
            "subject" => "test subject",
            "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13"
          },
          "id" => "4b9331a0-1f69-4df0-a746-6d2a09704b0f",
          "links" => %{"self" => "/v1/notes/4b9331a0-1f69-4df0-a746-6d2a09704b0f"},
          "type" => "notes"},
        %{"attributes" =>
          %{"author" => "John Doe", "body" => "blah",
            "posted_at" => nil,
            "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
            "subject" => "test subject",
            "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13"
          },
          "id" => "d4880268-eae5-4215-8843-82dd086ecf1c",
          "links" => %{"self" => "/v1/notes/d4880268-eae5-4215-8843-82dd086ecf1c"},
          "type" => "notes"},
        %{"attributes" =>
          %{"author" => "Madeleine L'Engle",
            "body" => "science fantasy novel written",
            "posted_at" => nil,
            "recipients" => ["decisiv:mlengle:6f698a0f-2e74-4273-987c-c781f2b44841"],
            "subject" => "A Wrinkle in Time",
            "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13"
          },
          "id" => "0e9d9364-814c-454e-beab-b726c9a63b05",
          "links" => %{"self" => "/v1/notes/0e9d9364-814c-454e-beab-b726c9a63b05"},
          "type" => "notes"}
      ]
    ]
  end

  describe "with list response" do
    test "returns valid maps with id", state do
      output = Decisiv.JsonApi.Parser.parse(state[:data_response])

      assert is_list(output)
      assert length(output) == 3
      assert List.first(output)["id"]
    end
  end

  describe "with single response" do
    test "returns map with id", state do
      output = Decisiv.JsonApi.Parser.parse(List.first(state[:data_response]))

      refute is_list(output)
      assert output["id"]
    end
  end
end
