defmodule Decisiv.ApiClient do
  @client_name Application.get_env(:ex_decisiv_api_client, :client_name)
  @timeout Application.get_env(:ex_decisiv_api_client, :timeout, 500)
  @version Mix.Project.config[:version]

  alias Decisiv.DynamoDB
  @moduledoc """
  Documentation for Decisiv.ApiClient.
  """

  @doc """
  Issues a request to a JSON API endpoint.

  Valid options are:
  * :params
  * :data
  * :headers
  * :options
  """
  def request(method, url, options \\ []) do
    params       = Keyword.get(options, :params)
    data         = Keyword.get(options, :data)
    headers      = Keyword.get(options, :headers, default_headers())
    http_options = Keyword.get_lazy(options, :options, fn ->
      if params, 
      do: [{:params, UriQuery.params(params)}] ++ default_options(), 
      else: default_options()
    end)

    body = if data, do: Poison.encode!(%{data: data}), else: ""

    case HTTPoison.request(method, url, body, headers, http_options) do
      # Decisiv.ApiClient.Notes.get("invalid_uuid") was returning {:ok, nil}
      # It was establishing a connection which gave an ok and returned nil.
      # ensure we check the status code 404 and return a not_found error
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:ok, resp} -> {:ok, Poison.decode!(resp.body)}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Generates a value used in the User-Agent header, used to identify callers.

  ## Examples

      iex> Decisiv.ApiClient.user_agent()
      "ExApiClient/0.1.0/client_name"

  """
  def user_agent do
    "ExApiClient/" <> @version <> "/" <> @client_name
  end

  @doc """
  Returns the default timeout value, in msecs.

  ## Examples

      iex> Decisiv.ApiClient.timeout()
      500

  """
  def timeout do
    @timeout
  end

  @doc """
  Returns the endpoint of a specific service.

  ## Examples

      iex> Decisiv.ApiClient.url_for(:notes)
      "http://localhost:3112"

  """
  def url_for(service_name) do
    response = DynamoDB.get_item(service_name)
    response["Item"]["endpoint"]
  end

  defp default_options do
    [timeout: timeout(), recv_timeout: timeout()]
  end

  defp default_headers do
    Map.new
    |> Map.put("Accept", "application/vnd.api+json")
    |> Map.put("Content-Type", "application/vnd.api+json")
    |> Map.put("User-Agent", user_agent())
  end
end
