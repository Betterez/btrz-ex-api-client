defmodule BtrzExApiClient do
  @moduledoc """
  Main module to handle requests to the Betterez's APIs.
  """

  require OpenTelemetry.Tracer
  require Logger

  alias BtrzExApiClient.Types

  @client_version Mix.Project.config()[:version]
  @allowed_methods [:get, :post, :put, :patch, :delete]

  defp http_client do
    Application.get_env(:btrz_ex_api_client, :http_client) || BtrzExApiClient.HTTPoison
  end

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
    defexception type: "authentication_error",
                 code: "UNAUTHORIZED",
                 status: 401,
                 message: "Unauthorized"
  end

  defmodule InvalidRequestError do
    @moduledoc """
    Invalid request errors arise when your request has invalid parameters.
    """
    @derive Jason.Encoder
    defexception type: "invalid_request_error", code: nil, status: nil, message: nil
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
    opts = Keyword.merge([hackney: [pool: :default], timeout: 60_000, recv_timeout: 60_000], opts)
    url = request_url(endpoint, query)
    method = action |> to_string() |> String.upcase()

    OpenTelemetry.Tracer.with_span "HTTP #{method}", %{
      kind: :client,
      attributes: %{"http.method" => method, "http.url" => url}
    } do
      request_headers =
        headers
        |> create_headers()
        |> maybe_inject_trace_context()
        |> maybe_put_grafana_trace_id()
        |> maybe_put_amzn_trace_id()

      result =
        http_client().request(
          action,
          url,
          Jason.encode!(body),
          request_headers,
          opts
        )

      set_response_span_status(result)
      handle_response(result)
    end
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

  defp maybe_inject_trace_context(headers) do
    :otel_propagator_text_map.inject([])
    |> Enum.reduce(headers, fn {key, value}, acc ->
      [{to_string(key), to_string(value)} | acc]
    end)
  end

  defp maybe_put_grafana_trace_id(headers) do
    case current_trace_id() do
      id when is_binary(id) ->
        [{"x-grafana-trace-id", id} | headers]

      _ ->
        headers
    end
  end

  defp current_trace_id do
    span_ctx = OpenTelemetry.Tracer.current_span_ctx()

    cond do
      span_ctx == :undefined ->
        nil

      not OpenTelemetry.Span.is_valid(span_ctx) ->
        nil

      true ->
        id =
          span_ctx
          |> OpenTelemetry.Span.hex_trace_id()
          |> to_string()

        if id == "" or id == String.duplicate("0", 32) do
          nil
        else
          id
        end
    end
  end

  defp maybe_put_amzn_trace_id(headers) do
    case Keyword.get(Logger.metadata(), :amzn_trace_id) do
      id when is_binary(id) and id != "" and id != "-" ->
        [{"x-amzn-trace-id", id} | headers]

      _ ->
        headers
    end
  end

  defp set_response_span_status({:ok, %{status_code: status}}) when status >= 500 do
    OpenTelemetry.Tracer.set_attributes(%{"http.status_code" => status})
    OpenTelemetry.Tracer.set_status(:error, "HTTP #{status}")
  end

  defp set_response_span_status({:ok, %{status_code: status}}) do
    OpenTelemetry.Tracer.set_attributes(%{"http.status_code" => status})
  end

  defp set_response_span_status({:error, _}) do
    OpenTelemetry.Tracer.set_status(:error, "connection error")
  end

  defp maybe_put_key(headers, nil), do: headers
  defp maybe_put_key(headers, x_api_key), do: [{"x-api-key", x_api_key} | headers]

  defp maybe_put_token(headers, opts) do
    cond do
      opts[:internal] === true ->
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

  defp handle_response({:ok, %{status_code: 401}}) do
    {:error, %AuthenticationError{}}
  end

  defp handle_response({:ok, %{body: body, status_code: status_code}}) do
    error_struct =
      try do
        %{"message" => message, "code" => code} =
          body
          |> process_response_body()

        case status_code do
          status_code when status_code in [400, 404] ->
            %InvalidRequestError{
              message: message,
              status: status_code,
              code: code
            }

          _ ->
            %APIError{code: code, message: message, status: status_code}
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
