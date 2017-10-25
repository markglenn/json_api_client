defmodule JsonApiClient.Middleware.StatsLogger do
  @moduledoc """
  Middleware that logs stats about the request, usually added by `JsonApiClient.Middleware.StatsTracker`
  """
  require Logger

  @log_level Application.get_env(:json_api_client, :log_level)

  def call(request, next, options) do
    log_level = Access.get(options, :log_level, @log_level)

    {microseconds, {status, response}} = :timer.tc fn -> next.(request) end

    stats = [total_ms: microseconds / 1_000]
    |> Enum.concat(stats_from_request(request))
    |> Enum.concat(stats_from_response(response))

    log stats, log_level

    {status, response}
  end

  defp stats_from_response(response) do
    timers = Enum.reverse(get_in(response.attributes, [:stats, :timers]) || [])

    {stats, _} = Enum.reduce(timers, {[], 0}, fn ({name, ms}, {result, ms_spent_elsewhere}) ->
      {[{"#{name}_ms", ms - ms_spent_elsewhere} | result], ms}
    end)

    stats
  end

  defp stats_from_request(request) do
    [url: request.url]
  end

  def log(stats, log_level) do
    Logger.log log_level, fn ->
      to_logfmt(stats)
    end
  end

  defp to_logfmt(enum) do
    enum
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join(" ")
  end
end
