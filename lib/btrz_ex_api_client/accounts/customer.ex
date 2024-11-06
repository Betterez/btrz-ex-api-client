defmodule BtrzExApiClient.Accounts.Customer do
  @moduledoc """
  Available Account endpoints in `btrz-api-accounts`.
  """
  use BtrzExApiClient.API

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "customers"
  end

  def merge_path(id) do
    path() <> "/merge/" <> id
  end

  def get_merge(id, headers \\ [], opts \\ []) do
    BtrzExApiClient.request(:get, merge_path(id), [], %{}, headers, opts)
  end
end
