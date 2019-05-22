defmodule BtrzExApiClient.Accounts.Lexicon do
  @moduledoc """
  Available Lexicon endpoints in `btrz-api-accounts`.
  """
  use BtrzExApiClient.API, [:create]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "lexicons"
  end

  def buscompany_path() do
    path() <> "/buscompany"
  end

  def buscompany(opts \\ []) do
    BtrzExApiClient.request(:get, buscompany_path(), [], %{}, opts)
  end
end
