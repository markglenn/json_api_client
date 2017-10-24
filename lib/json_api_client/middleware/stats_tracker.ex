defmodule JsonApiClient.Middleware.StatsTracker do

  def call(request, next, [wrap: {middleware, middleware_options}]) do
    {microseconds, result} = :timer.tc fn -> middleware.call(request, next, middleware_options) end
    timer_tuple = {middleware, microseconds / 1_000_000}
    result
    |> update_in([:stats], &(&1 || %{}))
    |> update_in([:stats, :timers], &(&1 || []))
    |> update_in([:stats, :timers], &[timer_tuple | &1])
  end
  
end
