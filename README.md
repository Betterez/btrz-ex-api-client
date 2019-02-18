# BtrzExApiClient

Elixir Betterez's APIs client.

## Documentation

API documentation at HexDocs [https://hexdocs.pm/btrz_ex_api_client](https://hexdocs.pm/btrz_ex_api_client)

## Installation

```elixir
def deps do
  [
    {:btrz_ex_api_client, "~> 0.1.0"}
  ]
end
```

## Configuration
Add the services base endpoints (mandatory)

```elixir
config :btrz_ex_api_client, :services,
  accounts: "http://localhost:3050/accounts/",
  webhooks: "http://localhost:4000/webhooks/"
  # ... etc
```

If you will need the Betterez internal JWT (inter-application auth) you have provide your secret keys in your config file (it's optional depending you will use internal token)

```elixir
config :btrz_ex_api_client, :internal_token,
  main_secret: "A_SECRET_KEY",
  secondary_secret: "A_SECRET_KEY"
```

## Basic usage

Depending your resource, it will implement the basic CRUD actions and will be invoked as follows:

  * `BtrzExApiClient.{RESOURCE}.create/2`
  * `BtrzExApiClient.{RESOURCE}.retrieve/2`
  * `BtrzExApiClient.{RESOURCE}.update/3`
  * `BtrzExApiClient.{RESOURCE}.list/2`
  * `BtrzExApiClient.{RESOURCE}.delete/3`

The endpoints will return `{:ok, response}` or `{:error, ERROR_STRUCT}`, depending the case.

## Posible errors
  * `%APIConnectionError{}` - Failure to connect to Betterez's API.
  * `%AuthenticationError{}` - Failure to properly authenticate yourself in the request.
  * `%InvalidRequestError{}` - Invalid request errors arise when your request has invalid parameters.
  * `%APIError{}` - Other generic errors

## Adding new endpoints
Please be careful with the folder structure, this example is under `lib/btrz_ex_api_client/accounts/`
```elixir
defmodule BtrzExApiClient.Accounts.User do
  use BtrzExApiClient.API, [:list, :create, :retrieve, :delete, :update]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "users"
  end
end
```

You might want to add custom routes, i.e: a POST accounts/users/import:

```elixir
defmodule BtrzExApiClient.Accounts.User do
  use BtrzExApiClient.API, [:list, :create, :retrieve, :delete, :update]

  def path do
    Application.get_env(:btrz_ex_api_client, :services)[:accounts] <> "users"
  end

  def import_path() do
    path() <> "/import"
  end

  def import(data, opts \\ []) do
    BtrzExApiClient.request(:post, import_path(), [], data, opts)
  end
end
```

## Betterez Auth
Betterez API's use the `x-api-key` and `Authorization` headers, depending the endpoint, they can be send via the `opts` param:

  * `BtrzExApiClient.Accounts.User.list([x_api_key: my_x_api_key])` - will add the `x-api-key` header.
  * `BtrzExApiClient.Accounts.User.list([x_api_key: my_x_api_key, internal: true])` - will request an internal token to the Betterez provider using the config keys and will add it to the `Authorization` header (using the Bearer JWT).
  * `BtrzExApiClient.Accounts.User.list([x_api_key: x_api_key, token: my_token])` - will add the user token to the `Authorization` header (using the Bearer JWT).
