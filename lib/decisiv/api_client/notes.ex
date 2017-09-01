defmodule ApiClient.Notes do
  @api_details %{scheme: "http", host: "localhost", port: 3112, version: "v1"}
  @endpoint_name "notes"

  def all do
    case HTTPoison.get(url) do
     {:ok, res} -> {:ok, Poison.decode!(res.body)["data"]}
     {:error, err} -> {:error, :service_unavailable}
    end
  end

  @doc """
  Create a Note based on data map

  Returns `%{:ok, response}`
  """
  def create(data) do
    case HTTPoison.post(url, Poison.encode!(data), content_type) do
      {:ok, res} -> {:ok, Poison.decode!(res.body)["data"]}
      {:error, err} -> {:error, err}
    end
  end

  defp url do
    "#{scheme}://#{host}:#{port}/#{version}/#{endpoint}"
  end

  defp content_type do
    %{"Content-type" => "application/json"}
  end

  defp scheme,   do: @api_details[:scheme]
  defp host,     do: @api_details[:host]
  defp port,     do: @api_details[:port]
  defp version,  do: @api_details[:version]
  defp endpoint, do: @endpoint_name
end
