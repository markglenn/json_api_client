defmodule JsonApiClient.Middleware.DocumentParser do
  @behaviour JsonApiClient.Middleware
  @moduledoc """
  HTTP client JSON API doucment parser.
  """

  alias JsonApiClient.{RequestError, Response, Parser}
  import JsonApiClient.Instrumentation

  def call(request, next, _options) do
    with {:ok, response} <- call_next(request, next),
         {:ok, parsed}   <- track_stats(:parse_document, fn -> parse_response(response) end )
    do
      {:ok, parsed}
    end
  end

  defp call_next(request, next) do
    case next.(request) do
      {:ok, _} = result -> result
      {:error, error} -> track_stats(:parse_document, {:error, error})
    end
  end

  defp parse_response(response) do
    with {:ok, doc} <- parse_document(response.doc)
    do
      {:ok, %{response | doc: doc}}
    else
      {:error, error} ->
        {:error, %RequestError{
          message: "Error Parsing JSON API Document",
          original_error: error,
          status: response.status,
          attributes: response.attributes
        }
      }
    end
  end

  defp parse_document(""), do: {:ok, nil}
  defp parse_document(json) do
    Parser.parse(json)
  end
end
