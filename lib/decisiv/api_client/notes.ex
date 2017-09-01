defmodule ApiClient.Notes do
  @api_details %{scheme: "http", host: "localhost", port: 3112, version: "v1"}
  @endpoint_name "notes"

  def all do
    case HTTPoison.get(url) do
     {:ok, res} -> {:ok, decoded_body_data(res)}
     {:error, err} -> {:error, :service_unavailable}
    end
  end

  @doc """
  Create a Note based on note map

  Returns `%{:ok, response}`
  """
  def create(note) do
    case HTTPoison.post(url, encode_data(note), content_type) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Update a Note based on the updated note map
  parms:
    id: The UUID as a string to updated
    note: The elixir map with the data attributes to update.

  Returns `%{:ok, response}`
  """
  def update(id, note) do
    case HTTPoison.patch("#{url}/#{id}", encode_data(note), content_type) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, err} -> {:error, err}
    end
  end

  def url do
    "#{scheme}://#{host}:#{port}/#{version}/#{endpoint}"
  end


  defp encode_data(data) do
    data
    |> Poison.encode!
  end

  defp decoded_body_data(resp) do
    Poison.decode!(resp.body)["data"]
  end

  defp content_type, do: %{"Content-type" => "application/vnd.api+json"}
  defp scheme,   do: @api_details[:scheme]
  defp host,     do: @api_details[:host]
  defp port,     do: @api_details[:port]
  defp version,  do: @api_details[:version]
  defp endpoint, do: @endpoint_name
end
