defmodule ApiClient.NotesTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  import Mock

  setup_with_mocks([
    {Decisiv.ApiClient, [:passthrough], [url_for: fn(:notes) -> "http://0.0.0.0:3112" end]}
  ]) do
    [
      note: %{
        topic: "decisiv:notes:0a4984c9-945a-4f4a-8caa-8f4ed0c094f4",
        subject: "Great Job!",
        author: "decisiv:user:01157108-E9DE-4785-BC7D-FFA42B62D874",
        recipients: ["decisiv:jskinner:05C8E078-217B-4469-B3A6-3021834C1917"],
        body: "Fantastic job on this case =)"
      },
    ]
  end

  describe ".create" do
    test "a new note", context do
      use_cassette to_string(context.test), match_requests_on: [:query, :request_body] do
        {:ok, resp} = ApiClient.Notes.create(context.note)

        assert resp["topic"] == context.note[:topic]
        assert resp["id"]
      end
    end
  end

  describe ".update" do
    test "an existing note", context do
      use_cassette to_string(context.test), match_requests_on: [:query, :request_body] do
        {:ok, note} = ApiClient.Notes.create(context.note)
        {:ok, resp} = ApiClient.Notes.update(note["id"], %{context.note | subject: "new subject"})

        assert resp["subject"] == "new subject"
      end
    end
  end

  describe ".get" do
    test "get an existing note", context do
      use_cassette to_string(context.test), match_requests_on: [:query, :request_body] do
        {:ok, note} = ApiClient.Notes.create(context.note)
        {:ok, resp} = ApiClient.Notes.get(note["id"])

        assert resp == note
      end
    end
  end

  describe ".all" do
    test "retrieves all records", context do
      use_cassette to_string(context.test), match_requests_on: [:query, :request_body] do
        for n <- 1..3 do
          {:ok, _} = ApiClient.Notes.create(%{context.note | subject: "subject#{n}"})
        end

        {:ok, resp} = ApiClient.Notes.all(page: %{number: "1", size: "3"})
        assert length(resp) == 3
      end
    end
  end

end
