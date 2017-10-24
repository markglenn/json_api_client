defmodule JsonApiClient.Middleware.DocumentParser do
  @behaviour JsonApiClient.Middleware
  @moduledoc """
  HTTP client JSON API doucment parser.
  """

  alias JsonApiClient.{RequestError, Response, Parser}
  import JsonApiClient.Instrumentation

  def call(request, next, _options) do
    with {:ok, response, stats} <- call_next(request, next),
         {:ok, parsed, parsing_stats}   <- parse_response(response, stats)
    do
      {:ok, parsed, parsing_stats}
    end
  end

  defp call_next(request, next) do
    case next.(request) do
      {:ok, _, _} = result -> result
      {:error, error, stats} ->
        add_empty_stats({:error, %RequestError{
          original_error: error,
          message: "Error completing HTTP request: #{error.reason}"
        }}, stats)
    end
  end

  defp parse_response(response, stats) do
    with {:ok, doc, stats} <- parse_document(response.body, stats)
    do
      {:ok, %Response{
        status: response.status_code,
        doc: doc,
        headers: response.headers,
      }, stats}
    else
      {:error, error, stats} ->
        {:error, %RequestError{
          message: "Error Parsing JSON API Document",
          original_error: error,
          status: response.status_code,
        }, stats}
    end
  end

  defp parse_document("", stats), do: add_empty_stats({:ok, nil}, stats)
  defp parse_document(json, stats) do
    track_stats(:parse_document, fn ->
      Parser.parse(json)
    end, stats)
  end

  defp add_empty_stats(result, stats) do
    track_stats(:parse_document, result, stats)
  end
end
