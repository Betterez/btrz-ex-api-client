defmodule BtrzExApiClient.HTTPClient do
  @moduledoc false

  alias BtrzExApiClient.Types

  @callback request(
              method :: Types.methods(),
              url :: String.t(),
              body :: map(),
              headers :: Type.headers()
            ) :: {:ok, response :: term()} | Type.error()
end
