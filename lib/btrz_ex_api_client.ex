defmodule BtrzExApiClient do
  @moduledoc """
  Main module to handle requests to the Betterez's APIs.
  """

  alias BtrzExApiClient.Types

  @http_client Application.get_env(:btrz_ex_api_client, :http_client) || BtrzExApiClient.HTTPoison
  @client_version Mix.Project.config()[:version]
  @allowed_methods [:get, :post, :put, :patch, :delete]

  defmodule APIConnectionError do
    @moduledoc """
    Failure to connect to Betterez's API.
    """
    @derive Jason.Encoder
    defexception type: "api_connection_error", code: nil, message: nil
  end

  defmodule APIError do
    @moduledoc """
    API errors cover any other type of problem (e.g., a temporary problem with
    Betterez's servers) and are extremely uncommon.
    """
    @derive Jason.Encoder
    defexception type: "api_error", code: nil, status: nil, message: nil
  end

  defmodule AuthenticationError do
    @moduledoc """
    Failure to properly authenticate yourself in the request.
    """
    @derive Jason.Encoder
    defexception type: "authentication_error", code: nil, status: nil, message: nil
  end

  defmodule InvalidRequestError do
    @moduledoc """
    Invalid request errors arise when your request has invalid parameters.
    """
    @derive Jason.Encoder
    defexception type: "invalid_request_error", code: nil, status: nil, message: nil, param: nil
  end

  @doc """
  This function will prepare and do the request through the HTTP client and will handle success and errors responses.

  ## headers

    * `:x_api_key` - Optional. This value will be placed in the `x-api-key` header.
    * `:internal` - Optional. Boolean. If `true` it will use the main/secondary keys (passed via config) for getting an internal JWT to be set in the `Authorization` header. Defaults to `false`.
    * `:token` - Optional. Set the JWT in the `Authorization` header. If `:internal` option is `true`, this option will be discarded.

  ## options

    Using the HTTPoison options (https://hexdocs.pm/httpoison/HTTPoison.Request.html)

  """
  @spec request(
          Types.methods(),
          String.t(),
          iolist(),
          map(),
          keyword(),
          keyword()
        ) ::
          {:error,
           %BtrzExApiClient.APIConnectionError{}
           | %BtrzExApiClient.APIError{}
           | %BtrzExApiClient.AuthenticationError{}
           | %BtrzExApiClient.InvalidRequestError{}}
          | {:ok, term()}
  def request(action, endpoint, query, body, headers, opts \\ [])
      when action in @allowed_methods do
    opts = Keyword.merge([hackney: [pool: :default]], opts)

    @http_client.request(
      action,
      request_url(endpoint, query),
      Jason.encode!(body),
      create_headers(headers),
      opts
    )
    |> handle_response
  end

  defp request_url(endpoint) do
    endpoint
  end

  defp request_url(endpoint, []) do
    endpoint
  end

  defp request_url(endpoint, data) do
    base_url = request_url(endpoint)
    query_params = BtrzExApiClient.Utils.encode_data(data)
    "#{base_url}?#{query_params}"
  end

  defp create_headers(opts) do
    [
      {"User-Agent", "BtrzExApiClient/#{@client_version}"},
      {"Content-Type", "application/json"},
      {"Accept", "Application/json; Charset=utf-8"}
    ]
    |> maybe_put_key(opts[:x_api_key])
    |> maybe_put_token(opts)
  end

  defp maybe_put_key(headers, nil), do: headers
  defp maybe_put_key(headers, x_api_key), do: [{"x-api-key", x_api_key} | headers]

  defp maybe_put_token(headers, opts) do
    cond do
      Keyword.has_key?(opts, :internal) ->
        {:ok, token, _claims} =
          BtrzAuth.internal_auth_token(Application.get_env(:btrz_ex_api_client, :internal_token))

        [{"Authorization", "Bearer #{token}"} | headers]

      Keyword.has_key?(opts, :token) ->
        [{"Authorization", "Bearer #{opts[:token]}"} | headers]

      true ->
        headers
    end
  end

  defp handle_response({:ok, %{body: body, status_code: status_code}})
       when status_code in 200..299 do
    {:ok, process_response_body(body)}
  end

  defp handle_response({:ok, %{body: body, status_code: status_code}}) do
    error_struct =
      try do
        %{"message" => message} =
          error =
          body
          |> process_response_body()
          |> Map.fetch!("error")

        case status_code do
          status_code when status_code in [400, 404] ->
            %InvalidRequestError{
              message: message,
              status: status_code,
              code: error["code"],
              param: error["param"]
            }

          401 ->
            %AuthenticationError{message: message, status: status_code}

          _ ->
            %APIError{message: message, status: status_code}
        end
      rescue
        _ ->
          %APIError{message: "", status: status_code}
      end

    {:error, error_struct}
  end

  defp handle_response({:error, %{reason: reason}}) do
    {:error, %APIConnectionError{message: "Network Error: #{reason}"}}
  end

  defp process_response_body(""), do: %{}
  defp process_response_body(body), do: Jason.decode!(body)
end
