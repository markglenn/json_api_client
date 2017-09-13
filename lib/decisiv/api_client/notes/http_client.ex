defmodule ApiClient.Notes.HTTPClient do
  @behaviour ApiClient.Notes.Behaviour

  @json_data_body %{data: %{attributes: %{}}}
  @endpoint "notes"
  @api_version "v1"

  def all(options \\ []) do
    query_params = Decisiv.Options.to_query_string(options)
    request_url = if query_params, do: "#{url()}?#{query_params}", else: url()

    case HTTPoison.get(request_url, headers(), options()) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, _err} -> {:error, :service_unavailable}
    end
  end

  def create(note) do
    case HTTPoison.post(url(), encode_data(note), headers(), options()) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, err} -> {:error, err}
    end
  end

  def update(id, note) do
    case HTTPoison.patch("#{url()}/#{id}", encode_data(note), headers(), options()) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, err} -> {:error, err}
    end
  end

  def url do
   "#{service_url()}/#{@endpoint}"
  end

  defp options do
    [timeout: Decisiv.ApiClient.timeout(), recv_timeout: Decisiv.ApiClient.timeout()]
  end

  defp encode_data(data) do
    @json_data_body
    |> put_in([:data, :attributes], data)
    |> Poison.encode!
  end

  defp decoded_body_data(resp) do
    Poison.decode!(resp.body)["data"]
  end

  defp headers do
    Map.new
    |> Map.put("Accept", "application/vnd.api+json")
    |> Map.put("Content-Type", "application/vnd.api+json")
    |> Map.put("User-Agent", Decisiv.ApiClient.user_agent())
  end

  defp service_url do
    "#{Decisiv.ApiClient.url_for(:notes)}/#{@api_version}"
  end
end
