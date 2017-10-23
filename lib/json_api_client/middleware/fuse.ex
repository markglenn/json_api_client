defmodule JsonApiClient.Middleware.Fuse do
  @behaviour JsonApiClient.Middleware

    @moduledoc """
    Circuit Breaker middleware using [fuse](https://github.com/jlouis/fuse)
    ### Options
    - `:name` - fuse name (defaults to 'json_api_client')
    - `:opts` - fuse options (see fuse docs for reference)
    """

  @defaults {{:standard, 2, 10_000}, {:reset, 60_000}}

  def call(env, next, options) do
    opts = options || []
    name = Keyword.get(opts, :name, "json_api_client")

    case :fuse.ask(name, :sync) do
      :ok ->
        run(env, next, name)

      :blown ->
        {:error, "Unavailable"}

      {:error, :not_found} ->
        :fuse.install(name, Keyword.get(opts, :opts, @defaults))
        run(env, next, name)
    end
  end

  defp run(env, next, name) do
    case next.(env) do
      {:error, error} ->
        :fuse.melt(name)
        {:error, error}
      success -> success
    end
  end
end
