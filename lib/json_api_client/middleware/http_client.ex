defmodule JsonApiClient.Middleware.HTTPClient do
  @behaviour JsonApiClient.Middleware
  @moduledoc """
  HTTP client Middleware based on HTTPoison library.
  """

  import JsonApiClient.Instrumentation

  def call(%{method: method, url: url, body: body, headers: headers, http_options: http_options}, _, _) do
    track_stats(:request, fn ->
      HTTPoison.request(method, url, body, headers, http_options)
    end, %{})
  end
end
