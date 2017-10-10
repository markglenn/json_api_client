defmodule JsonApiClient.FieldValidationTest do
  use ExUnit.Case
  doctest JsonApiClient.FieldValidation, import: true

  alias JsonApiClient.FieldValidation

  describe "valid?" do
    test "either fields and requred fields don't exist" do
      assert {:ok} = FieldValidation.valid?("doc", %{}, %{})
    end

    test "either fields are missing" do
      validation = FieldValidation.valid?("doc", %{either_fields: [:bar]}, %{})
      assert {:error, "A 'doc' MUST contain at least one of the following members: bar"} = validation
    end

    test "required fields are issing" do
      validation = FieldValidation.valid?("doc", %{required_fields: [:foo]}, %{})
      assert {:error, "A 'doc' MUST contain the following members: foo"} = validation
    end

    test "required fields and either fields exist" do
      assert {:ok} = FieldValidation.valid?("doc", %{required_fields: [:foo]}, %{bar: "value1", foo: "value2"})
    end
  end
end