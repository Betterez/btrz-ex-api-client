defmodule BtrzExApiClient.Accounts do
  @moduledoc false
  use BtrzExApiClient.API, [:request]

  def path(endpoint) do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> endpoint
  end
end

defmodule BtrzExApiClient.Inventory do
  @moduledoc false
  use BtrzExApiClient.API, [:request]

  def path(endpoint) do
    Application.get_env(:btrz_ex_api_client, :services)[:inventory] <> endpoint
  end
end

defmodule BtrzExApiClient.Operations do
  @moduledoc false
  use BtrzExApiClient.API, [:request]

  def path(endpoint) do
    Application.get_env(:btrz_ex_api_client, :services)[:operations] <> endpoint
  end
end

defmodule BtrzExApiClient.Webhooks do
  @moduledoc false
  use BtrzExApiClient.API, [:request]

  def path(endpoint) do
    Application.get_env(:btrz_ex_api_client, :services)[:webhooks] <> endpoint
  end
end
