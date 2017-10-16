defmodule JsonApiClient.HTTPClient do
  alias JsonApiClient.{Response, RequestError}

  @moduledoc """
  The HTTP client backend behaviour for the library.
  """

  @doc ~S"""
  Issues an HTTP request with the given method to the given url.

  Args:
    * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`,
      `:delete`, etc.)
    * `url` - target url as a binary string or char list
    * `body` - request body as JSON string.
    * `headers` - HTTP headers (e.g., `[{"Accept", "application/json"}]`)
    * `options` - Keyword list of options

  This function returns `{:ok, response}` if the request is successful, `{:error, reason}` otherwise.
  """
  @callback request(atom, binary, any, Keyword.t, Keyword.t) :: {:ok, Response.t} | {:error, RequestError.t}
end

defmodule JsonApiClient.HTTPClient.HTTPoison do
  @behaviour JsonApiClient.HTTPClient

  alias JsonApiClient.{Response, RequestError, Parser}

  @moduledoc """
  Default HTTP client backend.
  """

  def request(method, url, body, headers, http_options) do
    case HTTPoison.request(method, url, body, headers, http_options) do
      {:ok, response} -> parse_response(response)
      {:error, error} ->
        {:error, %RequestError{
          original_error: error,
          message: "Error completing HTTP request: #{error.reason}",
        }}
    end
  end

  defp parse_response(response) do
    with {:ok, doc} <- parse_document(response.body)
    do
      {:ok, %Response{
        status: response.status_code,
        doc: doc,
        headers: response.headers,
      }}
    else
      {:error, error} ->
        {:error, %RequestError{
          message: "Error Parsing JSON API Document",
          original_error: error,
          status: response.status_code,
        }}
    end
  end

  defp parse_document(""), do: {:ok, nil}
  defp parse_document(json), do: Parser.parse(json)
end
