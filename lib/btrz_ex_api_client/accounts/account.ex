defmodule BtrzExApiClient.Accounts.Account do
  @moduledoc """
  Available Account endpoints in `btrz-api-accounts`.
  """
  use BtrzExApiClient.API, [:retrieve]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "accounts"
  end
end
