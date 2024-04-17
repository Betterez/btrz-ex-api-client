defmodule BtrzExApiClient.Operations.Manifest.DispatchReporting do
  @moduledoc """
  Available Manifest endpoints in `btrz-api-operations`.
  """
  use BtrzExApiClient.API, [:retrieve]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:operations] <> "manifests/dispatch/reporting"
  end
end
