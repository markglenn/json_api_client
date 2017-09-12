defmodule ApiClient.Notes do
  @defaults [page: nil, sort: nil, fields: nil, filter: nil]
  @notes_api Application.get_env(:ex_decisiv_api_client, :notes_api)

  alias Decisiv.Options
  alias Decisiv.ApiClient

  @moduledoc """
  Documentation for ApiClient.Notes
  """

  @doc """
  List all the NotesTest

  params:
    options: Set of options that are available, with no specific order
      page: %{size: string, number: string , offset: string}
      sort: string
      fields: %{}

  ## Example
    ApiClient.Notes.all()
    ApiClient.Notes.all(page: %{size: "10"})
    ApiClient.Notes.all(page: %{size: "10"}, fields: %{notes: "id,topic,recipients"})
  """
  def all(options \\ []) do
    options = generate_keyword_list(options)

    @notes_api.all(options)
  end

  @doc """
  Create a Note based on note map

  Returns `%{:ok, response}`
  """
  def create(note) do
    @notes_api.create(note)
  end

  @doc """
  Update a Note based on the updated note map
  parms:
    id: The UUID as a string to updated
    note: The elixir map with the data attributes to update.

  Returns `%{:ok, response}`
  """
  def update(id, note) do
    @notes_api.update(id, note)
  end

  defp generate_keyword_list(options) do
    merged_list = Keyword.merge(@defaults, options)
    merged_list
    |> Enum.reject(&(&1 |> elem(1) |> is_nil)) # remove all nil values
  end
end
