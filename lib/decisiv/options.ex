defmodule Decisiv.Options do
  @moduledoc """
    Documentation for Decisiv.Options
  """

  @doc """
  Takes a KeyWord list and converts to URI Encoded parameters for query String

  ## Examples

    iex> Decisiv.Options.to_query_string([fields: %{notes: "topic,id"}, page: %{number: "25"}])
    "fields[notes]=topic,id&page[number]=25"

    iex> Decisiv.Options.to_query_string([fields: %{notes: "topic,id"}, page: %{number: "25", size: "1"}])
    "fields[notes]=topic,id&page[number]=25&page[size]=1"

    iex> Decisiv.Options.to_query_string([fields: %{notes: "topic,id"}])
    "fields[notes]=topic,id"

    iex> Decisiv.Options.to_query_string([page: %{size: "25", number: "1"}])
    "page[number]=1&page[size]=25"

    iex> Decisiv.Options.to_query_string([page: %{number: "25", size: "1"},
    ...> fields: %{notes: "topic,id", recipients: "id"},
    ...> filter: %{views: %{user_id: "393ad8a7-6339-49bb-968f-e40cd633174c"}},
    ...> sort: "topic"])
    "page[number]=25&page[size]=1&fields[notes]=topic,id&fields[recipients]=id&filter[views][user_id]=393ad8a7-6339-49bb-968f-e40cd633174c&sort=topic"

    iex> Decisiv.Options.to_query_string([])
    ""
  """
  def to_query_string(options) do
    Enum.map(options, fn(option) -> parse(option) end)
      |> Enum.join("&")
  end

  defp parse(option) when is_tuple(option) and is_map(elem(option, 1)) do
    param_name = elem(option,0)
    elem(option, 1)
      |> Enum.map(fn({key, value}) -> "#{Atom.to_string(param_name)}[#{key}]#{parse(value)}" end)
      |> Enum.join("&")

  end

  defp parse(option) when is_map(option) do
    option
    |> Enum.map( fn({key, value}) -> "[#{key}]#{parse(value)}" end)
    |> Enum.join("&")
  end

  defp parse(option) when is_tuple(option) do
    Tuple.to_list(option)
      |> Enum.chunk(2)
      |> Enum.reduce(%{}, fn([key, value], accumulator) -> Map.put(accumulator, key, value) end)
      |> URI.encode_query
  end

  defp parse(value) do
    "=#{value}"
  end
end
