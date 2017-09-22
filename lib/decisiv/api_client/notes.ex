defmodule ApiClient.Notes do
  @defaults [page: nil, sort: nil, fields: nil, filter: nil]
  @transport_protocol Application.get_env(:ex_decisiv_api_client,
                                          :notes_transport_protocol)

  @json_data_body %{data: %{attributes: %{}}}
  @endpoint "notes"
  @api_version "v1"

  alias Decisiv.Options
  alias Decisiv.ApiClient
  alias Decisiv.JsonApi.Parser

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
    keyword_options = generate_keyword_list(options)
    query_params = Options.to_query_string(keyword_options)
    request_url = if query_params, do: "#{url()}?#{query_params}", else: url()

    case @transport_protocol.get(request_url, headers(), options()) do
      {:ok, res} -> {:ok, Parser.parse(decoded_body_data(res))}
      {:error, _err} -> {:error, :service_unavailable}
    end
  end

  @doc """
  Create a Note based on note map

  Returns `%{:ok, response}`
  """
  def create(note) do
    case @transport_protocol.post(url(),
      encode_data(note), headers(), options()) do
      {:ok, res} -> {:ok, Parser.parse(decoded_body_data(res))}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Update a Note based on the updated note map
  parms:
    id: The UUID as a string to updated
    note: The elixir map with the data attributes to update.

  Returns `%{:ok, response}`
  """
  def update(id, note) do
    case @transport_protocol.patch("#{url()}/#{id}",
      encode_data(note), headers(), options()) do
      {:ok, res} -> {:ok, Parser.parse(decoded_body_data(res))}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Get a Note based on the ID
  parms:
    id: The UUID as a string to updated

  Returns `%{:ok, response}`
  """
  def get(id) do
    case @transport_protocol.get("#{url()}/#{id}",
      headers(), options()) do
      # Decisiv.ApiClient.Notes.get("invalid_uuid") was returning {:ok, nil}
      # It was establishing a connection which gave an ok and returned nil.
      # ensure we check the status code 404 and return a not_found error
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:ok, res} -> {:ok, Parser.parse(decoded_body_data(res))}
      {:error, err} -> {:error, err}
    end
  end

  def url do
    "#{service_url()}/#{@endpoint}"
  end

  defp generate_keyword_list(options) do
    merged_list = Keyword.merge(@defaults, options)
    merged_list
    |> Enum.reject(&(&1 |> elem(1) |> is_nil)) # remove all nil values
  end

  defp options do
    [timeout: ApiClient.timeout(), recv_timeout: ApiClient.timeout()]
  end

  defp encode_data(data) do
    @json_data_body
    |> put_in([:data, :attributes], data)
    |> Poison.encode!
  end

  defp decoded_body_data(resp) do
    Poison.decode!(resp.body)["data"]
  end

  defp headers do
    Map.new
    |> Map.put("Accept", "application/vnd.api+json")
    |> Map.put("Content-Type", "application/vnd.api+json")
    |> Map.put("User-Agent", ApiClient.user_agent())
  end

  defp service_url do
    "#{ApiClient.url_for(:notes)}/#{@api_version}"
  end
end
