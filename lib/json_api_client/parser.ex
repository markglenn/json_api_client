defmodule JsonApiClient.Parser do
  @moduledoc """
  Parses a JSON API Document
  """

  alias JsonApiClient.{Document, FieldValidation, Schema}

  def parse(map, protocol) do
    field_value(:Document, protocol, ensure_jsonapi_field_exist(map))
  end

  defp field_value(_, _, nil), do: {:ok, nil}

  defp field_value(name, %{array: true} = field_definition, value) when is_list(value) do
    array_field_value(name, field_definition, value)
  end

  defp field_value(name, %{array: :allow} = field_definition, value) when is_list(value) do
    array_field_value(name, field_definition, value)
  end

  defp field_value(name, %{array: :allow} = field_definition, value) do
    field_value(name, Map.put(field_definition, :array, false), value)
  end

  defp array_field_value(name, field_definition, value) do
    Enum.reduce_while(Enum.reverse(value), {:ok, []}, fn(entry, {result, acc}) ->
      case field_value(name, Map.put(field_definition, :array, false), entry) do
        {:error, error} -> {:halt, {:error, error}}
        {:ok, value} -> {:cont, {:ok, [value | acc]}}
      end
    end)
  end

  defp field_value(name, %{array: true}, value) do
    {:error, "The field '#{name}' must be an array."}
  end

  defp field_value(name, _, value) when is_list(value) do
    {:error, "The field '#{name}' cannot be an array."}
  end

  defp field_value(name, %{representation: :object, value_representation: value_representation}, %{} = value) do
    representations = Map.new(value, fn {k, v} -> {k, value_representation} end)
    compute_values(representations, value)
  end

  defp field_value(_, %{representation: :object}, %{} = value) do
    {:ok, value}
  end

  defp field_value(name, %{representation: :object}, _) do
    {:error, "The field '#{name}' must be an object."}
  end

  defp field_value(name, %{representation: representation, fields: fields} = field_definition, data) do
    case FieldValidation.valid?(name, field_definition, data) do
      {:ok} ->
        case compute_values(fields, data) do
          {:error, error} -> {:error, error}
          {:ok, values} -> {:ok, struct(representation, values)}
        end
      error -> error
    end
  end

  defp field_value(name, _, value) do
    {:ok, value}
  end

  def compute_values(fields, data) do
    Enum.reduce_while(fields, {:ok, %{}}, fn({k, definition}, {code, acc}) ->
      case field_value(k, definition, data[to_string(k)]) do
        {:error, error} -> {:halt, {:error, error}}
        {:ok, value} -> {:cont, {:ok, Map.put(acc, k, value)}}
      end
    end)
  end

  defp ensure_jsonapi_field_exist(map) do
    Map.put_new(map, "jsonapi", %{"version" => "1.0", "meta" => %{}})
  end
end
