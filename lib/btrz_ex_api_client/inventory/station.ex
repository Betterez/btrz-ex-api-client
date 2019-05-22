defmodule BtrzExApiClient.Inventory.Station do
  @moduledoc """
  Available Station endpoints in `btrz-api-inventory`.
  """
  use BtrzExApiClient.API, [:list]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:inventory] <> "stations"
  end

  def import_path() do
    path() <> "/import"
  end

  def import(data, opts \\ []) do
    BtrzExApiClient.request(:post, import_path(), [], data, opts)
  end
end
