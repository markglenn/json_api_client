defmodule JsonApiClient.Middleware.Runner do
  @moduledoc """
  Responsible for Middlewares stack execution.
  """

  alias JsonApiClient.Middleware.Factory

  def run(request) do
    middleware_runner(Factory.middlewares()).(request)
  end

  defp middleware_runner([]) do end

  defp middleware_runner([{middleware, options} | rest]) do
    fn(request) ->
      middleware.call(request, middleware_runner(rest), options)
    end
  end
end
