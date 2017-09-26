defmodule ApiClient.Notes.HTTPClient do
  @moduledoc """
  HTTPClient which handles all request to the Notes API Endpoints
  """

  @behaviour ApiClient.Notes.Behaviour

  @endpoint "notes"
  @api_version "v1"

  alias Decisiv.ApiClient
  alias Decisiv.JsonApi.Parser

  def all(options \\ []) do
    query_params = UriQuery.params(options)

    ApiClient.request(:get, url(), params: query_params)
    |> handle_response
  end

  def create(note) do
    ApiClient.request(:post, url(), data: %{attributes: note})
    |> handle_response
  end

  def update(id, note) do
    ApiClient.request(:patch, "#{url()}/#{id}", data: %{attributes: note})
    |> handle_response
  end

  def get(id) do
    ApiClient.request(:get, "#{url()}/#{id}")
    |> handle_response
  end

  def handle_response(response) do
    case response do
      {:ok, resp} -> {:ok, Parser.parse(resp["data"])}
      {:error, err} -> {:error, err}
    end
  end

  def url do
   "#{service_url()}/#{@endpoint}"
  end

  defp service_url do
    "#{ApiClient.url_for(:notes)}/#{@api_version}"
  end

end
