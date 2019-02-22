defmodule BtrzExApiClient.Accounts.Permission do
  @moduledoc false
  use BtrzExApiClient.API, [:list]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "permissions"
  end

  def import_path() do
    path() <> "/import"
  end

  def import(data, opts \\ []) do
    BtrzExApiClient.request(:post, import_path(), [], data, opts)
  end
end
