defmodule JsonApiClient.Parsers.FieldValidation do
  @moduledoc """
  Describes a JSON API Document field validation
  """

  def valid?(name, field_definition, data) do
    Enum.reduce_while(to_validate(name, field_definition, data), :ok, fn validation, _ ->
      case validate_fields(validation[:fields], validation[:method], data, validation[:error]) do
        {:ok} -> {:cont, {:ok}}
        error -> {:halt, error}
      end
    end)
  end

  defp to_validate(name, field_definition, data) do
    either_fields   = field_definition[:either_fields] || []
    required_fields = field_definition[:required_fields] || []
    to_validate = [
      %{
        fields: field_definition[:either_fields] || [],
        method: :validate_either_fields,
        error: "A '#{name}' MUST contain at least one of the following members: #{Enum.join(either_fields, ", ")}"
      },
      %{
        fields: field_definition[:required_fields] || [],
        method: :validate_required_fields,
        error: "A '#{name}' MUST contain following members: #{Enum.join(required_fields, ", ")}"
      }
    ]
  end

  defp validate_fields(fields, method, data, error) do
    case !Enum.any?(fields) || apply(JsonApiClient.Parsers.FieldValidation, method, [fields, data]) do
      true -> {:ok}
      false -> {:error, error}
    end
  end

  def validate_required_fields(fields, data) do
    fields |> Enum.all?(&(Map.has_key?(data, &1)))
  end

  def validate_either_fields(fields, data) do
    fields |> Enum.any?(&(Map.has_key?(data, &1)))
  end
end