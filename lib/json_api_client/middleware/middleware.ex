defmodule JsonApiClient.Middleware do
  @moduledoc """
  The HTTP client middleware behaviour for the library.
  """

  @doc ~S"""
  Manipulates a Request and Response objects.
  If the Request should be processed `next.(env)` has to be called.

  Args:

    * `env` - holds http request properties:
    - `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`,
      `:delete`, etc.)
    - `url` - target url as a binary string or char list
    - `body` - request body as JSON string.
    - `headers` - HTTP headers (e.g., `[{"Accept", "application/json"}]`)
    - `http_options` - Keyword list of options

  This function returns `{:ok, response}` if the request is successful, `{:error, reason}` otherwise.
  `response` - HTTP response with the following properties:
    - `body` - body as JSON string.
    - `status_code`- HTTP Status code
    - `headers`- HTTP headers (e.g., `[{"Accept", "application/json"}]`)

  """
  @type env :: %{method: atom, url: binary, body: any, headers: Keyword.t, http_options: Keyword.t}
  @callback call(env, ((env) -> {:ok, %{body: any, status_code: binary, headers: Keyword.t}} | {:error, any}),
                options :: any) :: {:ok, %{body: any, status_code: binary, headers: Keyword.t}} | {:error, any}
end
