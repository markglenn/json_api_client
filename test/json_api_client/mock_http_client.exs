defmodule JsonApiClient.HTTPClient.TestMock do
  @behaviour JsonApiClient.HTTPClient

  @moduledoc false

  def request(_method, _url, _body, _headers, _http_options) do
    %{status_code: 200, headers: [], body: ""}
  end
end