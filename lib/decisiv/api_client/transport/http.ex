defmodule ApiClient.Transport.Http do
  @moduledoc """
    Transport.Http which handles
  """

  @behaviour ApiClient.Transport

  def get(url, headers \\ [], options \\ []) do
    HTTPoison.get(url, headers, options)
  end

  def patch(url, data, headers \\ [], options \\ []) do
    HTTPoison.patch(url, data, headers, options)
  end

  def post(url, data, headers \\ [], options \\ []) do
    HTTPoison.post(url, data, headers, options)
  end
end
