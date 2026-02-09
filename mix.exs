defmodule BtrzExApiClient.MixProject do
  use Mix.Project

  @github_url "https://github.com/Betterez/btrz-ex-api-client"
  @version "0.9.4"

  def project do
    [
      app: :btrz_ex_api_client,
      version: @version,
      source_url: @github_url,
      homepage_url: @github_url,
      elixir: "~> 1.13",
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
      {:btrz_ex_auth_api, "~> 1.3.0"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:mox, "~> 0.4", only: :test}
    ]
  end

  defp docs do
    [
      main: "BtrzExApiClient",
      source_ref: "v#{@version}",
      source_url: @github_url,
      extras: ["README.md"],
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      Accounts: [
        BtrzExApiClient.Accounts.Account,
        BtrzExApiClient.Accounts.Lexicon,
        BtrzExApiClient.Accounts.Permission,
        BtrzExApiClient.Accounts.Role,
        BtrzExApiClient.Accounts.User
      ],
      Inventory: [
        BtrzExApiClient.Inventory.Station
      ],
      Operations: [
        BtrzExApiClient.Operations.Ticket,
        BtrzExApiClient.Operations.Transaction,
        BtrzExApiClient.Operations.Manifest
      ],
      Webhooks: [
        BtrzExApiClient.Webhooks.Subscription,
        BtrzExApiClient.Webhooks.Undelivered,
        BtrzExApiClient.Webhooks.Failed
      ]
    ]
  end
end
