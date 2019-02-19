defmodule BtrzExApiClient.Types do
  @moduledoc """
  BtrzExApiClient types.
  """

  @typedoc """
  The default error tuple.
  """
  @type error() :: {:error, reason :: term()}

  @typedoc """
  The allowed HTTP methods.

  Methods are defined as atoms.
  """
  @type methods() :: :delete | :get | :post | :put | :patch

  @typedoc """
  HTTP headers.

  Headers are sent and received as lists of two-element tuples containing two strings,
  the header name and header value.
  """
  @type headers() :: [{header_name :: String.t(), header_value :: String.t()}]
end
