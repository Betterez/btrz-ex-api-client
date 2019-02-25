defmodule BtrzExApiClient.Webhooks.Subscription do
  @moduledoc false
  use BtrzExApiClient.API, [:list]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:webhooks] <> "subscriptions"
  end
end
