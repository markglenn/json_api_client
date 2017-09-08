defmodule Decisiv.DynamoDB do
  @environment Application.get_env(:ex_decisiv_api_client, :decisiv_environment)

  alias ExAws.Dynamo
  alias Dynamo.Decoder

  @moduledoc """
    Documentation for Decisiv.DynamoDB
  """

  @doc """
  Returns a map with details of a specific service

  ## Examples

    iex> Decisiv.DynamoDB.get_item(:notes)
    %{"Item" => %{"endpoint" => "http://localhost:3112", "service" => "notes"}}

  """
  def get_item(service) do
    services_table()
    |> Dynamo.get_item(%{service: service})
    |> ExAws.request!
    |> Decoder.decode
  end

  defp services_table do
    "service_discovery_#{@environment}"
  end
end
