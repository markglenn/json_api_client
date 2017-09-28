defmodule Decisiv.ApiClient do
  @client_name Application.get_env(:ex_decisiv_api_client, :client_name)
  @timeout Application.get_env(:ex_decisiv_api_client, :timeout, 500)
  @version Mix.Project.config[:version]

  @moduledoc """
  Documentation for Decisiv.ApiClient.
  """

  def request(base_url), do: %{base_url: base_url}
  
  def id(req, id), do: Map.put(req, :resource_id, id)
  
  def method(req, method), do: Map.put(req, :method, method)

  def fetch(req, options \\ []), do: req |> method(:get) |> execute(options)

  def execute(req, options \\ []) do
    req = Enum.reduce(options, req, fn ({option, value}, acc) -> 
      apply(__MODULE__, option, [acc, value])
    end)
    exec_request(req)
  end

  def exec_request(req) do
    method       = Map.get(req, :method)
    base_url     = Map.get(req, :base_url)
    resource_id  = Map.get(req, :resource_id)
    url = [base_url, resource_id]
          |> Enum.reject(&is_nil/1)
          |> Enum.join("/")
    params       = Map.get(req, :params)
    data         = Map.get(req, :data)
    headers      = Map.get(req, :headers, default_headers())
    http_options = Map.get_lazy(req, :options, fn ->
      if params,
      do: [{:params, UriQuery.params(params)} | default_options],
      else: default_options()
    end)

    body = if data, do: Poison.encode!(%{data: data}), else: ""

    case HTTPoison.request(method, url, body, headers, http_options) do
      # Decisiv.ApiClient.Notes.get("invalid_uuid") was returning {:ok, nil}
      # It was establishing a connection which gave an ok and returned nil.
      # ensure we check the status code 404 and return a not_found error
      {:ok, %HTTPoison.Response{status_code: 404}} -> {:error, :not_found}
      {:ok, resp} -> {:ok, atomize_keys(Poison.decode!(resp.body))}
      {:error, err} -> {:error, err}
    end
  end

  def atomize_keys(map) when is_map(map) do
    for {key, val} <- map, into: %{} do
      {String.to_atom(key), atomize_keys(val)}
    end
  end
  def atomize_keys(list) when is_list(list), do: Enum.map(list, &atomize_keys/1)
  def atomize_keys(val), do: val

  def exec(x), do: x

  defp default_options do
    [timeout: timeout(), recv_timeout: timeout()]
  end

  defp default_headers do
    %{
      "Accept"       => "application/vnd.api+json",
      "Content-Type" => "application/vnd.api+json",
      "User-Agent"   => user_agent()              ,
    }
  end

  defp user_agent do
    "ExApiClient/" <> @version <> "/" <> @client_name
  end

  defp timeout do
    @timeout
  end
end

defmodule Decisiv.ApiClient.Request do
  defstruct(
    data:     nil,
    errors:   nil,
    meta:     nil,
    jsonapi:  nil,
    links:    nil,
    included: nil,
    _query: %{}, 
  )
end

defmodule Decisiv.ApiClient.Response do
  defstruct(
    data:     nil,
    errors:   nil,
    meta:     nil,
    jsonapi:  nil,
    links:    nil,
    included: nil,
  )
end

defmodule Decisiv.ApiClient.Resource do
  defstruct(
    id:            nil,
    type:          nil,
    attributes:    nil,
    relationships: nil,
    meta:          nil,
  )
end

defmodule Decisiv.ApiClient.Links do
  defstruct self: nil, related: nil
end
