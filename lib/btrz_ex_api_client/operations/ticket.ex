defmodule BtrzExApiClient.Operations.Ticket do
  @moduledoc false
  use BtrzExApiClient.API, [:retrieve]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:operations] <> "tickets"
  end
end
