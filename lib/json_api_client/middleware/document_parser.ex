defmodule JsonApiClient.Middleware.DocumentParser do
  @behaviour JsonApiClient.Middleware
  @moduledoc """
  HTTP client JSON API doucment parser.
  """

  alias JsonApiClient.{RequestError, Response, Parser}
  import JsonApiClient.Instrumentation

  def call(request, next, _options) do
    with {:ok, response, instrumentation} <- call_next(request, next),
         {:ok, parsed}   <- parse_response(response, instrumentation)
    do
      {:ok, parsed}
    end
  end

  defp call_next(request, next) do
    case next.(request) do
      {:ok, _, _} = result -> result
      {:error, error, instrumentation} ->
        add_empty_instrumentation({:error, %RequestError{
          original_error: error,
          message: "Error completing HTTP request: #{error.reason}"
        }}, instrumentation)
    end
  end

  defp parse_response(response, instrumentation) do
    with {:ok, doc, instrumentation} <- parse_document(response.body, instrumentation)
    do
      {:ok, %Response{
        status: response.status_code,
        doc: doc,
        headers: response.headers,
      }, instrumentation}
    else
      {:error, error, instrumentation} ->
        {:error, %RequestError{
          message: "Error Parsing JSON API Document",
          original_error: error,
          status: response.status_code,
        }, instrumentation}
    end
  end

  defp parse_document("", instrumentation), do: add_empty_instrumentation({:ok, nil}, instrumentation)
  defp parse_document(json, instrumentation) do
    instrumentation(:parse_document, fn ->
      Parser.parse(json)
    end, instrumentation)
  end

  defp add_empty_instrumentation(result, instrumentation) do
    add_instrumentation(result, :parse_document, instrumentation, 0)
  end
end
