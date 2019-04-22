defmodule BtrzExApiClient.HTTPoison do
  @moduledoc false
  require Protocol
  Protocol.derive(Jason.Encoder, HTTPoison.Error)

  @behaviour BtrzExApiClient.HTTPClient

  @impl true
  def request(action, endpoint, encoded_body, headers) do
    HTTPoison.request(action, endpoint, encoded_body, headers, hackney: [pool: :default])
  end
end
