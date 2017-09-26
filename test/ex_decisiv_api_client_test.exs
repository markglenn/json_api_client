defmodule Decisiv.ApiClientTest do
  use ExUnit.Case
  doctest Decisiv.ApiClient, except: [url_for: 1]

  import Mock

  alias Decisiv.ApiClient

  defmacro with_service_discovery_mock([do: code]) do
    quote do
      response = %{
        "Item" => %{
          "endpoint" => %{"S" => "http://localhost:3112"}, 
          "service" => %{"S" => "notes"}
        }
      }
      with_mock ExAws, [request!: fn (_) -> response end] do
        unquote(code)
      end
    end
  end

  test ".url_for" do
    with_service_discovery_mock do
      assert ApiClient.url_for(:notes) == "http://localhost:3112"
    end
  end

  describe ".request" do
    # TODO: write request tests 
  end
end
