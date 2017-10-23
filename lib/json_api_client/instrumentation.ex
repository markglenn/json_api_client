defmodule JsonApiClient.Instrumentation do
  @moduledoc false

  require Logger

  @log_level Application.get_env(:json_api_client, :log_level)

  def instrumentation(action, fun, instrumentation) do
    {microseconds, result} = :timer.tc(fun)
    ms = microseconds / 1_000

    add_instrumentation(result, action, instrumentation, ms)
  end

  def add_instrumentation(result, action, instrumentation, time) do
    Tuple.append(result, DeepMerge.deep_merge(%{time: %{action => time}}, instrumentation))
  end

  def log(opts, log_level \\ @log_level) do
    if log_level do
      Logger.log(:warn, Poison.encode!(opts))
    end
  end
end
