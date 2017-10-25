defmodule JsonApiClient.Config.SASLLogs do
  @moduledoc false

  def suppress(_min_level, :info, :report, {:progress, _data}), do: :skip
end
