defmodule BtrzExApiClient.Webhooks.Failed do
  @moduledoc """
  Available Failed endpoints in `btrz-api-webhooks`.
  """
  use BtrzExApiClient.API, [:create]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:webhooks] <> "failed"
  end
end
