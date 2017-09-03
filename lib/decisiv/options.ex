defmodule Decisiv.Options do

  def to_query_string(options) do
    Enum.map(options, fn(option) -> parse(option) end)
      |> Enum.join("&")
  end

  defp parse(option) when is_tuple(option) and is_map(elem(option, 1)) do
    param_name = elem(option,0)
    elem(option, 1)
      |> Enum.map(fn({key, value}) -> "#{Atom.to_string(param_name)}[#{key}]=#{String.trim(value)}" end)
      |> Enum.join("&")

  end

  defp parse(option) when is_tuple(option) do
    Tuple.to_list(option)
      |> Enum.chunk(2)
      |> Enum.reduce(%{}, fn([key, value], accumulator) -> Map.put(accumulator, key, value) end)
      |> URI.encode_query
  end
end
