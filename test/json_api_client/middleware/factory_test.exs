defmodule JsonApiClient.Middleware.FactoryTest do
  use ExUnit.Case
  doctest JsonApiClient.Middleware.Factory, import: true

  alias JsonApiClient.Middleware.Factory

  test "includes HTTPClient Middleware" do
    assert Enum.member?(Factory.middlewares(), {JsonApiClient.Middleware.HTTPClient, nil})
  end

  test "includes configured Middleware (HTTPClient Middleware is the last)" do
    [{JsonApiClient.Middleware.HTTPClient, _} | middlewares] = Factory.middlewares()
    configured  = {JsonApiClient.Middleware.Fuse, [{:opts, {{:standard, 2, 10_000}, {:reset, 60_000}}}]}

    Mix.Config.persist(json_api_client: [middlewares: [configured]])

    assert Factory.middlewares() == [configured, {JsonApiClient.Middleware.HTTPClient, nil}]

    Mix.Config.persist(json_api_client: [middlewares: [middlewares]])
  end
end