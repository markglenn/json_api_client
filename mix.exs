defmodule ExDecisivApiClient.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_decisiv_api_client,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "Decisiv Elixir ApiClient",
      description: description(),
      package: package(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.html": :test, "coveralls.post": :test],
      deps: deps(),
      source_url: "https://github.decisiv.net/PlatformServices/ex_decisiv_api_client",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.7.2", only: :test},
      {:ex_aws, "~> 1.1.4"},
      {:ex_doc, "~>0.16.3", only: :dev},
      {:httpoison, "~> 0.13.0"},
      {:poison, "~> 3.1"},
      {:mock, "~> 0.2.0", only: :test, runtime: false},
    ]
  end

  defp package do
    [
      organization: "decisiv",
      licenses: [""],
      maintainers: ["Julian Skinner", "Eduardo Carneiro", "Cloves Carneiro"],
      links: %{
        "Github" => "https://github.decisiv.net/PlatformServices/ex_decisiv_api_client"
      }
    ]
  end

  defp description do
    """
      Client package for accessing Elixir JSONApi services built at Decisiv
    """
  end

  defp aliases do
    [
      "ci": ["compile", "credo --strict", "coveralls"]
    ]
  end
end
