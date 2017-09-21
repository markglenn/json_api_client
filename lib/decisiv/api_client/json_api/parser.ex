defmodule Decisiv.JsonApi.Parser do
  @moduledoc """
    Parses a JSON API Response to a simple Map
  """

  @doc """
    Takes the JSON API Response starting from the "Data" key and only returns
    data we care about.
  """
  def parse([head | tail]) do
    [parse(head)] ++ parse(tail)
  end

  def parse([]), do: []

  def parse(%{"id" => id, "attributes" => attributes}) do
    Map.merge(
      %{"id" => id},
      attributes
    )
  end
end
