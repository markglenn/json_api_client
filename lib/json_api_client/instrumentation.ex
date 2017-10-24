defmodule JsonApiClient.Instrumentation do
  @moduledoc false

  require Logger

  @log_level Application.get_env(:json_api_client, :log_level)

  def track_stats(action, result, stats) when not is_function(result) do
    add_stats(result, action, stats, 0)
  end

  def track_stats(action, fun, stats) do
    {microseconds, result} = :timer.tc(fun)
    ms = microseconds / 1_000

    add_stats(result, action, stats, ms)
  end

  defp add_stats(result, action, stats, time) do
    Tuple.append(result, DeepMerge.deep_merge(%{time: %{action => time}}, stats))
  end

  def log(stats, log_level \\ @log_level) do
    if log_level do
      Logger.log(log_level, to_logfmt(Iteraptor.to_flatmap(stats)))
    end
  end

  defp to_logfmt(enum) do
    enum
    |> Enum.map(fn {k, v} -> "#{k}=#{v}" end)
    |> Enum.join(" ")
  end
end
