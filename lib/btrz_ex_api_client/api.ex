defmodule BtrzExApiClient.API do
  @moduledoc false
  defmacro __using__(opts) do
    quote do
      if :request in unquote(opts) do
        @doc """
        Request a generic endpoint in #{
          __MODULE__ |> to_string |> String.split(".") |> List.last()
        }
        """
        def request(action, endpoint, query \\ [], body \\ %{}, headers \\ [], request_opts \\ []) do
          BtrzExApiClient.request(action, path(endpoint), query, body, headers, request_opts)
        end
      end

      if :create in unquote(opts) do
        @doc """
        Create a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def create(data, headers \\ [], request_opts \\ []) do
          BtrzExApiClient.request(:post, path(), [], data, headers, request_opts)
        end
      end

      if :retrieve in unquote(opts) do
        @doc """
        Retrive a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()} by its ID
        """
        def retrieve(id, headers \\ [], request_opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:get, resource_url, [], [], headers, request_opts)
        end
      end

      if :update in unquote(opts) do
        @doc """
        Update a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def update(id, data, headers \\ [], request_opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:put, resource_url, [], data, headers, request_opts)
        end
      end

      if :list in unquote(opts) do
        @doc """
        List all #{__MODULE__ |> to_string |> String.split(".") |> List.last()}s
        """
        def list(headers \\ [], query \\ [], request_opts \\ []) when is_list(query) do
          BtrzExApiClient.request(:get, path(), query, [], headers, request_opts)
        end
      end

      if :delete in unquote(opts) do
        @doc """
        Delete a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def delete(id, data \\ [], headers \\ [], request_opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:delete, resource_url, [], data, headers, request_opts)
        end
      end
    end
  end
end
