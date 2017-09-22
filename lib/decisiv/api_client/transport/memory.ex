defmodule ApiClient.Transport.Memory do
  @moduledoc """
  This is the Mocked Client for Testing.
  """
  @behaviour ApiClient.Transport

  alias ApiClient.Transport.Memory
  alias Faker.{Name, Lorem}

  def get(_url, _headers, _options) do

  end

  def patch(_url, data, _headers, _options) do

  end

  def post(_url, data, _headers, _options) do

  end

  #
  # def all(_ \\ []) do
  #   resp = [%{
  #     "attributes" => %{
  #       "author" => Name.name,
  #       "body" => Lorem.word,
  #       "posted_at" => DateTime.to_string(DateTime.utc_now),
  #       "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
  #       "subject" => Lorem.word,
  #       "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13",
  #       "inserted_at" => DateTime.to_string(DateTime.utc_now),
  #       "updated_at" => DateTime.to_string(DateTime.utc_now)
  #     },
  #     "id" => "877be79a-d556-49c7-b737-650d82e776ae",
  #     "links" => %{"self" => "/v1/notes/877be79a-d556-49c7-b737-650d82e776ae"},
  #     "type" => "notes"
  #   },
  #   %{
  #     "attributes" => %{
  #       "author" => Name.name,
  #       "body" => Lorem.word,
  #       "posted_at" => nil,
  #       "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
  #       "subject" => Lorem.word,
  #       "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13",
  #       "inserted_at" => DateTime.to_string(DateTime.utc_now),
  #       "updated_at" => DateTime.to_string(DateTime.utc_now)
  #     },
  #     "id" => "0798f1e0-e445-4c7b-b124-d3a4bfa09a39",
  #     "links" => %{"self" => "/v1/notes/0798f1e0-e445-4c7b-b124-d3a4bfa09a39"},
  #     "type" => "notes"},
  #   %{
  #     "attributes" => %{
  #       "author" => Name.name,
  #       "body" => Lorem.word,
  #       "posted_at" => nil,
  #       "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
  #       "subject" => Lorem.word,
  #       "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13",
  #       "inserted_at" => DateTime.to_string(DateTime.utc_now),
  #       "updated_at" => DateTime.to_string(DateTime.utc_now)
  #     },
  #     "id" => "13cb430c-b583-441c-af7b-57d626928bfa",
  #     "links" => %{"self" => "/v1/notes/13cb430c-b583-441c-af7b-57d626928bfa"},
  #     "type" => "notes"
  #   }]
  #
  #   {:ok, resp}
  # end
  #
  # def create(note) do
  #   id = UUID.uuid4()
  #   note = note
  #           |> Map.put(:"inserted_at", DateTime.to_string(DateTime.utc_now))
  #           |> Map.put(:"updated_at", DateTime.to_string(DateTime.utc_now))
  #           |> Map.put(:"posted_at", nil)
  #
  #   resp = Map.new
  #     |> Map.put("id", id)
  #     |> Map.put("links", %{"self" => "/v1/notes/#{id}"})
  #     |> Map.put("type", "notes")
  #     |> Map.put("attributes", stringify_keys(note))
  #
  #   {:ok, resp}
  # end
  #
  # def update(id, note) do
  #   {:ok, all_notes_list} = Memory.all
  #   existing_note = Enum.at(all_notes_list,
  #     Enum.find_index(get_in(all_notes_list, [Access.all, "id"]),
  #       fn x ->
  #         x == id
  #       end
  #     )
  #   )
  #
  #   updated_note = Map.merge(existing_note["attributes"], stringify_keys(note))
  #
  #   note = Map.replace(existing_note, "attributes", updated_note)
  #
  #   {:ok, note}
  # end
  #
  # def get(id) do
  #   {:ok, %{
  #       "author" => Name.name,
  #       "body" => Lorem.word,
  #       "posted_at" => nil,
  #       "recipients" => ["decisiv:jskinner:6f698a0f-2e74-4273-987c-c781f2b44841"],
  #       "subject" => Lorem.word,
  #       "topic" => "decisiv:notes:c9a37d6f-578f-42c2-bea7-dd3d456a7c13",
  #     }
  #   }
  # end
  #
  # defp stringify_keys(note) do
  #   note
  #     |> Enum.reduce(%{}, fn ({key, val}, acc) ->
  #       Map.put(acc, Atom.to_string(key), val)
  #     end)
  # end
end
