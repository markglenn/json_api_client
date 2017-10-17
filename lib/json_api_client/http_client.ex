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
  `response` - HTTP response with the following properties:
    - `body` - body as JSON string.
    - `status_code`- HTTP headers (e.g., `[{"Accept", "application/json"}]`)
    - `headers`- HTTP headers (e.g., `[{"Accept", "application/json"}]`)

  """
  @callback request(atom, binary, any, Keyword.t, Keyword.t) :: {:ok, Response.t} | {:error, RequestError.t}
end

defmodule JsonApiClient.HTTPClient.HTTPoison do
  @behaviour JsonApiClient.HTTPClient

  alias JsonApiClient.{RequestError, ResponseParser}

  @moduledoc """
  Default HTTP client backend.
  """

  def request(method, url, body, headers, http_options) do
    HTTPoison.request(method, url, body, headers, http_options)
  end
end
