defmodule JsonApiClient.Middleware.StatsLogger do
  require Logger

  @log_level Application.get_env(:json_api_client, :log_level)

  def call(request, next, options) do
    log_level = Access.get(options, :log_level, @log_level)

    response = next.(request)

    stats = []
    |> Enum.concat(stats_from_request(request))
    |> Enum.concat(stats_from_response(response))

    log stats, log_level

    response
  end

  defp stats_from_response(response) do
    timers = Enum.reverse(get_in(response, [:stats, :timers]) || [])

    {stats, total} = Enum.reduce(timers, {[], 0}, fn ({module, ms}, {result, ms_spent_elsewhere}) ->
      name = module
      |> Module.split
      |> List.last
      |> Macro.underscore
      |> String.replace(~r/$/, "_ms")

      {[{name, ms - ms_spent_elsewhere} | result], ms}
    end)

    [{:json_api_client_ms, total} | stats]
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
