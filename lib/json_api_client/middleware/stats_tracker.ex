defmodule JsonApiClient.Middleware.StatsTracker do
  @moduledoc """
  Middleware that adds stats data to response. Usually to be logged by `JsonApiClient.Middleware.StatsLogger`.
  """

  def call(request, next, [wrap: {middleware, middleware_options}]) do
    {microseconds, {status, result}} = :timer.tc fn -> middleware.call(request, next, middleware_options) end
    timer_tuple = {middleware, microseconds / 1_000_000}

    attributes = result.attributes
    |> update_in([:stats], &(&1 || %{}))
    |> update_in([:stats, :timers], &(&1 || []))
    |> update_in([:stats, :timers], &[timer_tuple | &1])

    {status, %{result | attributes: attributes}}
  end

end
