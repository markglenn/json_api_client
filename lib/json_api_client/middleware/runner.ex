defmodule JsonApiClient.Middleware.Runner do
  @moduledoc """
  Responsible for Middlewares stack execution.
  """

  alias JsonApiClient.Middleware.Factory

  def run(env) do
    middleware_runner(Factory.middlewares()).(env)
  end

  defp middleware_runner([]) do end

  defp middleware_runner([{middleware, options} | rest]) do
    fn(env) ->
      middleware.call(env, middleware_runner(rest), options)
    end
  end
end
