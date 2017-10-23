defmodule JsonApiClient.Middleware.FuseTest do
  use ExUnit.Case
  doctest JsonApiClient.Middleware.Fuse, import: true

  import Mock
  alias JsonApiClient.Middleware.Fuse

  @request %{foo: "bar"}
  @options [{:name, "my circuit breaker"}, {:opts, {:standard, 1, 20_000}, {:reset, 10_000}}]

  test "returns error and doesn not call next middleware when circuit breaker is closed" do
    {:ok, agent} = Agent.start_link fn -> 0 end
    with_mocks(
      [
        {
          :fuse, [], [
            ask: fn("json_api_client", :sync) -> {:error, :not_found} end,
            ask: fn("json_api_client", :sync) -> :blown end,
            install: fn("json_api_client", {{:standard, 2, 10_000}, {:reset, 60_000}}) -> :ok end
          ]
        }
      ]
      ) do
        assert {:error, "Unavailable"} =  Fuse.call(@request, fn request ->
          Agent.update(agent, fn count -> count + 1 end)
          assert request == @request
        end, [])

        assert Agent.get(agent, fn count -> count end) == 0
    end
  end

  test "returns OK and calls next middleware when circuit breaker is opened" do
    {:ok, agent} = Agent.start_link fn -> 0 end
    with_mocks(
      [
        {
          :fuse, [], [
            ask: fn("json_api_client", :sync) -> {:error, :not_found} end,
            ask: fn("json_api_client", :sync) -> :ok end,
            install: fn("json_api_client", {{:standard, 2, 10_000}, {:reset, 60_000}}) -> :ok end
          ]
        }
      ]
      ) do
      Fuse.call(@request, fn request ->
        Agent.update(agent, fn count -> count + 1 end)
        assert request == @request
      end, [])

      assert Agent.get(agent, fn count -> count end) == 1
    end
  end

  test "uses name and configuration form otions" do
    with_mocks(
      [
        {
          :fuse, [], [
            ask: fn(name, :sync) ->
              check_name(name)
              {:error, :not_found}
            end,
            ask: fn(name, :sync) ->
              check_name(name)
              :ok
            end,
            install: fn(name, opts) ->
              check_name(name)
              check_options(opts)
              :ok
            end
          ]
        }
      ]
      ) do
      Fuse.call(@request, fn _env -> end, @options)
    end
  end

  defp check_name(name) do
    assert name == Keyword.get(@options, :name)
  end

  defp check_options(opts) do
    assert opts == Keyword.get(@options, :opts, %{})
  end
end

