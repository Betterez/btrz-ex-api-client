defmodule BtrzExApiClient.Operations.Transaction do
  @moduledoc """
  Available Transaction endpoints in `btrz-api-operations`.
  """
  use BtrzExApiClient.API, [:retrieve]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:operations] <> "transactions"
  end
end
