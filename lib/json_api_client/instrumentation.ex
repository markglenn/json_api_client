defmodule JsonApiClient.Instrumentation do
  @moduledoc false

  require Logger

  @log_level Application.get_env(:json_api_client, :log_level)

  def track_stats(action, {status, response}) do
    add_stats({status, response}, action, 0)
  end

  def track_stats(action, fun) do
    {microseconds, result} = :timer.tc(fun)
    ms = microseconds / 1_000

    add_stats(result, action, ms)
  end

  defp add_stats({status, response}, action, time) do
    {status, assign(response, %{time: %{action => time}})}
  end

  defp assign(response, stats) do
    %{response | attributes: DeepMerge.deep_merge(response.attributes, %{stats: stats})}
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
