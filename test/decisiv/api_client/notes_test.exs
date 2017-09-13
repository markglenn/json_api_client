defmodule ApiClient.NotesTest do
  use ExUnit.Case

  setup do
    [
      note: %{
        topic: "decisiv:notes:#{UUID.uuid4()}",
        subject: Faker.Lorem.word,
        author: Faker.Name.name,
        recipients: ["decisiv:jskinner:#{UUID.uuid4()}"],
        body: Faker.Lorem.word
      },
    ]
  end

  describe "with valid data" do
    test "creates a new note", context do
      {:ok, resp} = ApiClient.Notes.create(context.note)

      assert resp["attributes"]["subject"] == context.note[:subject]
      assert resp["attributes"]["inserted_at"]
    end
  end

  describe ".all" do
    test "retrieves all records" do
      {:ok, resp} = ApiClient.Notes.all()
      assert length(resp) == 3
    end
  end

  describe ".create" do
    test "a new note", context do
      {:ok, resp} = ApiClient.Notes.create(context.note)

      assert resp["attributes"]["topic"] == context.note[:topic]
      assert resp["id"]
    end
  end

  describe ".update" do
    test "an existing note", context do
      {:ok, resp} = ApiClient.Notes.update("0798f1e0-e445-4c7b-b124-d3a4bfa09a39", context.note)

      assert resp["attributes"]["topic"] == context.note[:topic]
    end
  end
end
