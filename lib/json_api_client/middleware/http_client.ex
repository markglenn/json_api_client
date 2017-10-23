defmodule JsonApiClient.Middleware.HTTPClient do
  @behaviour JsonApiClient.Middleware
  @moduledoc """
  HTTP client Middleware based on HTTPoison library.
  """

  def call(%{method: method, url: url, body: body, headers: headers, http_options: http_options}, _next, _options) do
    HTTPoison.request(method, url, body, headers, http_options)
  end
end
