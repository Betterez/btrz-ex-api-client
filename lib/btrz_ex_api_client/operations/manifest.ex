defmodule BtrzExApiClient.Operations.Manifest do
  @moduledoc """
  Available Manifest endpoints in `btrz-api-operations`.
  """
  use BtrzExApiClient.API, [:retrieve]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:operations] <> "manifests"
  end

  def dispatch_reporting_path(id) do
    path() <> "/dispatch/reporting/" <> id
  end

  def dispatch_reporting(id, headers \\ [], opts \\ []) do
    BtrzExApiClient.request(:get, dispatch_reporting_path(id), [], %{}, headers, opts)
  end
end
