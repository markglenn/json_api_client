defmodule ApiClient.Notes.Behaviour do
  @moduledoc """
  Defined contract for all things related to service API calls.
  """

  @doc """
  List all the records for a given set of data

  params:
    options: Set of options that are available, with no specific order
      page: %{size: string, number: string , offset: string}
      sort: string
      fields: %{}

  Returns `{:ok, %{}}` | `{:error, Atom.t}`
  """
  @callback all(options :: Keyword.t) :: {:ok, %{}} | {:error, Atom.t}

  @doc """
  Create a Note based on note map

  Returns `%{:ok, response}` | `{:error, String.t}`
  """
  @callback create(note :: Tuple.t) :: {:ok, %{}} | {:error, String.t}

  @doc """
  Update a Note based on the updated note map
  parms:
    id: The UUID as a string to updated
    note: The elixir map with the data attributes to update.

  Returns `%{:ok, %{}}` | {:error, String.t}
  """
  @callback update(id :: String.t, note :: Map.t)
    :: {:ok, %{}} | {:error, String.t}

  @doc """
  get a Note based on the id
  parms:
    id: The UUID as a string to updated

  Returns `%{:ok, %{}}` | {:error, String.t}
  """
  @callback get(id :: String.t)
    :: {:ok, %{}} | {:error, String.t}
end
