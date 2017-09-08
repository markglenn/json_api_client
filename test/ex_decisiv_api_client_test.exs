defmodule Decisiv.ApiClientTest do
  use ExUnit.Case
  doctest Decisiv.ApiClient, except: [url_for: 1]

  import Mock

  alias Decisiv.ApiClient

  test ".url_for" do
    with_mock ExAws, [request!: fn(_params) -> %{
      "Item" => %{"endpoint" => %{"S" => "http://localhost:3112"}, "service" => %{"S" => "notes"}}
    } end] do
      assert ApiClient.url_for(:notes) == "http://localhost:3112"
    end
  end
end
