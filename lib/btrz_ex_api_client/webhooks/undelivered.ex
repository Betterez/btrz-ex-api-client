defmodule BtrzExApiClient.Webhooks.Undelivered do
  @moduledoc """
  Available Undelivered endpoints in `btrz-api-webhooks`.
  """
  use BtrzExApiClient.API, [:create]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:webhooks] <> "undelivered"
  end
end
