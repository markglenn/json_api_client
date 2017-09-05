defmodule Decisiv.ApiClient do
  @version "0.1.0"
  @client_name Application.get_env(:ex_decisiv_api_client, :client_name)

  @moduledoc """
  Documentation for Decisiv.ApiClient.
  """

  @doc """
  Generates a value used in the User-Agent header, used to identify callers.

  ## Examples

      iex> Decisiv.ApiClient.user_agent
      "ExApiClient/0.1.0/client_name"

  """
  def user_agent do
    "ExApiClient/" <> @version <> "/" <> @client_name
  end
end
