defmodule ApiClient.Transport do
  @moduledoc """
  Defined contract for Http Transport Protocols.
  """

  @type headers :: [{atom, binary}] | [{binary, binary}] | %{binary => binary}

  @moduledoc """
  Defined contract for Http Transport Protocols.
  """
  @callback get(binary, headers, Keyword.t) ::
    {:ok, Response.t | AsyncResponse.t} | {:error, Error.t}

  @callback patch(binary, any, headers, Keyword.t) ::
    {:ok, Response.t | AsyncResponse.t} | {:error, Error.t}

  @callback post(binary, any, headers, Keyword.t) ::
    {:ok, Response.t | AsyncResponse.t} | {:error, Error.t}
end
