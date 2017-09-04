defmodule ApiClient.Notes do
  @api_details %{scheme: "http", host: "localhost", port: 3112, version: "v1"}
  @defaults [page: nil, sort: nil, fields: nil]
  @endpoint_name "notes"

  @doc """
  List all the NotesTest

  params:
    options: Set of options that are available, with no specific order
      page: %{size: string, number: string , offset: string}
      sort: string
      fields: %{}

  ## Example
    ApiClient.Notes.all()
    ApiClient.Notes.all(page: %{size: "10"})
    ApiClient.Notes.all(page: %{size: "10"}, fields: %{notes: "id,topic,recipients"})
  """
  def all(options \\ []) do
    options = generate_keyword_list(options)
    query_params = Decisiv.Options.to_query_string(options)

    case HTTPoison.get(url(), headers(), options()) do
     {:ok, res} -> {:ok, decoded_body_data(res)}
     {:error, _err} -> {:error, :service_unavailable}
    end
  end

  @doc """
  Create a Note based on note map

  Returns `%{:ok, response}`
  """
  def create(note) do
    case HTTPoison.post(url(), encode_data(note), headers(), options()) do
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
    case HTTPoison.patch("#{url()}/#{id}", encode_data(note), headers(), options()) do
      {:ok, res} -> {:ok, decoded_body_data(res)}
      {:error, err} -> {:error, err}
    end
  end

  def url do
    "#{scheme()}://#{host()}:#{port()}/#{version()}/#{endpoint()}"
  end

  defp options do
    [timeout: Decisiv.ApiClient.timeout(), recv_timeout: Decisiv.ApiClient.timeout()]
  end

  defp generate_keyword_list(options) do
    Keyword.merge(@defaults, options)
      |> Enum.into(%{})
      |> Enum.reject(fn {_,v} -> is_nil(v) end) # remove all nil values
  end

  defp encode_data(data) do
    data
    |> Poison.encode!
  end

  defp decoded_body_data(resp) do
    Poison.decode!(resp.body)["data"]
  end

  defp headers do
    Map.new
    |> Map.put("Accept", "application/vnd.api+json")
    |> Map.put("User-Agent", Decisiv.ApiClient.user_agent())
  end

  defp scheme,   do: @api_details[:scheme]
  defp host,     do: @api_details[:host]
  defp port,     do: @api_details[:port]
  defp version,  do: @api_details[:version]
  defp endpoint, do: @endpoint_name
end
