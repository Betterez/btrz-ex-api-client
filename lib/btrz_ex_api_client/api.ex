defmodule BtrzExApiClient.API do
  defmacro __using__(opts) do
    quote do
      if :request in unquote(opts) do
        @doc """
        Request a generic endpoint in #{
          __MODULE__ |> to_string |> String.split(".") |> List.last()
        }
        """
        def request(action, endpoint, query \\ [], body \\ %{}, opts \\ []) do
          BtrzExApiClient.request(action, path(endpoint), query, body, opts)
        end
      end

      if :create in unquote(opts) do
        @doc """
        Create a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def create(data, opts \\ []) do
          BtrzExApiClient.request(:post, path(), [], data, opts)
        end
      end

      if :retrieve in unquote(opts) do
        @doc """
        Retrive a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()} by its ID
        """
        def retrieve(id, opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:get, resource_url, [], [], opts)
        end
      end

      if :update in unquote(opts) do
        @doc """
        Update a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def update(id, data, opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:put, resource_url, [], data, opts)
        end
      end

      if :list in unquote(opts) do
        @doc """
        List all #{__MODULE__ |> to_string |> String.split(".") |> List.last()}s
        """
        def list(opts \\ [], query \\ []) when is_list(query) do
          BtrzExApiClient.request(:get, path(), query, [], opts)
        end
      end

      if :delete in unquote(opts) do
        @doc """
        Delete a(n) #{__MODULE__ |> to_string |> String.split(".") |> List.last()}
        """
        def delete(id, data \\ [], opts \\ []) when is_bitstring(id) do
          resource_url = Path.join(path(), id)
          BtrzExApiClient.request(:delete, resource_url, [], data, opts)
        end
      end
    end
  end
end
