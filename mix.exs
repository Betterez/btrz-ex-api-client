defmodule BtrzExApiClient.MixProject do
  use Mix.Project

  @github_url "https://github.com/Betterez/btrz-ex-api-client"
  @version "0.1.3"

  def project do
    [
      app: :btrz_ex_api_client,
      version: @version,
      source_url: @github_url,
      homepage_url: @github_url,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description()
    ]
  end

  def description do
    "Betterez API Client for Elixir"
  end

  def package do
    [
      name: "btrz_ex_api_client",
      maintainers: ["Betterez"],
      licenses: ["MIT"],
      links: %{"GitHub" => @github_url}
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
      {:httpoison, "~> 1.4"},
      {:jason, "~> 1.1"},
      {:btrz_ex_auth_api, "~> 0.10.4"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:mox, "~> 0.4", only: :test}
    ]
  end

  defp docs do
    [
      main: "BtrzExApiClient",
      source_ref: "v#{@version}",
      source_url: @github_url,
      extras: ["README.md"]
    ]
  end
end
