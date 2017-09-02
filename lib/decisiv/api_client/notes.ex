defmodule ApiClient.Notes do
  @api_details %{scheme: "http", host: "localhost", port: 3112, version: "v1"}
  @defaults [page_size: nil, page_num: nil, filter: nil, sort: nil, fields: nil]
  @endpoint_name "notes"

  @doc """
  List all the NotesTest

  params:
    options: Set of options that are available, with no specific order
      page_size: int
      page_num: int
      filter:
      fields: %{}

  ## Example
    ApiClient.Notes.all()
    ApiClient.Notes.all(page_size: 10)
    ApiClient.Notes.all(page_size: 10, fields: %{notes: "id,topic,recipients"})
  """
  def all(options \\ []) do
    options = generate_keyword_list(options)
    query_params = build_query_params(options)

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

  defp build_query_params(options) do
    unless Enum.empty?(options) do
      [head | tail] = options
        |> List.keysort(0) # sort so that we get fields first. BRITTLE!!!

      # do we have a fields tuple
      output = if Enum.member?(Tuple.to_list(head), :fields) do
          generate_fields_param(head)
        else # head is just a tuple with key / value, convert to a list, and encode
          encode_key_value(head)
        end

      q = unless Enum.empty?(tail) do
        tail
          |> URI.encode_query # encode them for query_string
      end

      [output, q]
        |> Enum.filter(fn(v) -> v != nil end)
        |> Enum.intersperse("&")
        |> List.to_string
    else
      ""
    end
  end

  @doc """
    Generates an URI encoded string based on key/value pairs

    Returns `key=value&key2=value2`
  """
  defp encode_key_value(tuple) do
    tuple
      |> Tuple.to_list
      |> Enum.chunk(2)
      |> Enum.reduce(%{}, fn([key, value], accumulator) -> Map.put(accumulator, key, value) end)
      |> URI.encode_query # encode them for query_string
  end
  @doc """
  Generates query string for fields based on map

  Returns `fields[notes]=id,recipients`
  """
  defp generate_fields_param(fields_tuple) do
    elem(fields_tuple, 1)
    |> Enum.map(fn({key, value}) -> "fields[#{key}]=#{String.trim(value)}" end)
    |> Enum.join("&") #
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
