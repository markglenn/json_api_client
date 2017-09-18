defmodule ApiClient.Notes.HTTPClient.HTTPClientTest do
  use ExUnit.Case, async: true

  import Mock

  @moduletag :live_integration_test

  setup_all do
    sample_id= create_note()
    note = %{
      topic: "decisiv:notes:#{UUID.uuid4()}",
      subject: Faker.Lorem.word,
      author: Faker.Name.name,
      recipients: ["decisiv:jskinner:#{UUID.uuid4()}"],
      body: Faker.Lorem.word
    }

    update_note = %{
      subject: Faker.Lorem.word
    }


    on_exit fn ->
      delete_note(sample_id)
    end

    [sample_id: sample_id, note: note, update_note: update_note]
  end

  describe "with valid data" do
    test "creates a new note", context do
      with_mock ExAws, [request!: fn(_params) -> %{
        "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
      } end] do
        {:ok, resp} = ApiClient.Notes.HTTPClient.create(context.note)

        assert resp["attributes"]["subject"] == context.note[:subject]
        assert resp["attributes"]["inserted_at"]

        delete_note(resp["id"])
      end
    end

    test "updates an existing note", context do
      with_mock ExAws, [request!: fn(_params) -> %{
        "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
      } end] do

        {:ok, resp} = ApiClient.Notes.HTTPClient.update(context.sample_id, context.update_note)

        assert resp["attributes"]["subject"] == context.update_note[:subject]
      end
    end
  end

  describe ".all" do
    test "retrieves all records" do
      with_mock ExAws, [request!: fn(_params) -> %{
        "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
      } end] do
        {:ok, resp} = ApiClient.Notes.HTTPClient.all()
        assert length(resp) == 1
      end
    end

    test "retrieve sparse fields" do
      with_mock ExAws, [request!: fn(_params) -> %{
        "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
      } end] do
        {:ok, resp} = ApiClient.Notes.HTTPClient.all(fields: %{notes: "topic,recipients"})

        check_map = Enum.at(resp, 0)["attributes"]
        assert ["topic", "recipients"] |> Enum.all?(&(Map.has_key?(check_map, &1)))
        refute ["subject", "author"] |> Enum.all?(&(Map.has_key?(check_map, &1)))
        # assert is_nil(resp["attributes"]["subject"])
      end
    end
  end

  defp delete_note(id) do
    HTTPoison.delete("http://localhost:3112/v1/notes/#{id}")
  end

  defp create_note() do
    with_mock ExAws, [request!: fn(_params) -> %{
      "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
    } end] do
      {:ok, resp} = ApiClient.Notes.HTTPClient.create(%{
        topic: "decisiv:notes:#{UUID.uuid4()}",
        subject: Faker.Lorem.word,
        author: Faker.Name.name,
        recipients: ["decisiv:jskinner:#{UUID.uuid4()}"],
        body: Faker.Lorem.word
      })

      resp["id"]
    end
  end
end
