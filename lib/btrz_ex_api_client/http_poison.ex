defmodule BtrzExApiClient.HTTPoison do
  @moduledoc false

  @behaviour BtrzExApiClient.HTTPClient

  @impl true
  def request(action, endpoint, encoded_body, headers) do
    HTTPoison.request(action, endpoint, encoded_body, headers, hackney: [pool: :default])
  end
end
