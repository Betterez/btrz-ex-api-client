defmodule BtrzExApiClientTest do
  use ExUnit.Case, async: true
  doctest BtrzExApiClient
  import Mox

  test "list users with the correct params" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, _headers, _opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list()
  end

  test "list users with the correct params using internal token" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers, _opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      {"Authorization", bearer} = find_header(headers, "Authorization")
      assert bearer =~ ~r/Bearer \w/u
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(internal: true)
  end

  test "list users with the correct params explicity without internal token" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers, _opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      assert find_header(headers, "Authorization") == nil
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(internal: false)
  end

  test "list users with the correct params using user token" do
    token =
      "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJidHJ6LWFwaS1jbGllbnQiLCJleHAiOjE1NTAyNDYzNjMsImlhdCI6MTU1MDI0NjI0MywiaXNzIjoiYnRyei1hcGktY2xpZW50IiwianRpIjoiYzE1OWRlZTktYzA3Yi00ZWVjLWFkYzEtZDlmMjE5ZmRlMDQzIiwibmJmIjoxNTUwMjQ2MjQyLCJzdWIiOnt9LCJ0eXAiOiJhY2Nlc3MifQ.Ca7SvDH5HZmjHA9uusIBw7cfP7RrKbMcNs_B9HHcIR_PZ5K9Hu3Y4L2BYhzUtwsojtoZmzmtXPM33IL7sCfPqw"

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers, _opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      assert {"Authorization", "Bearer " <> ^token} = find_header(headers, "Authorization")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(token: token)
  end

  test "list users with the correct params using x_api_key header" do
    key = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9"

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers, _opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(x_api_key: key)
  end

  test "import users with the correct params" do
    payload = %{
      "users" => [
        %{"id" => "1234bGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9", "email" => "test@betterez.com"}
      ]
    }

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, data, _headers, _opts ->
      assert action == :post

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users/import"

      assert Jason.decode!(data) == payload
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.import(payload)
  end

  test "call a custom path for Accounts service" do
    key = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9"
    query = [field: "val"]
    data = %{key: "val"}

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, reqdata, headers, _opts ->
      assert action == :get

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}a/path?field=val"

      assert reqdata == Jason.encode!(data)
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.request(:get, "a/path", query, data, x_api_key: key)
  end

  test "call a custom path for Inventory service" do
    key = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9"
    query = [field: "val"]
    data = %{key: "val"}

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, reqdata, headers, _opts ->
      assert action == :post

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:inventory]}a/path?field=val"

      assert reqdata == Jason.encode!(data)
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Inventory.request(:post, "a/path", query, data, x_api_key: key)
  end

  test "call a custom path for Operations service" do
    key = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9"
    query = [field: "val"]
    data = %{key: "val"}

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, reqdata, headers, _opts ->
      assert action == :put

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:operations]}a/path?field=val"

      assert reqdata == Jason.encode!(data)
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Operations.request(:put, "a/path", query, data, x_api_key: key)
  end

  test "call a custom path for Webhooks service" do
    key = "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9"
    query = [field: "val"]
    data = %{key: "val"}

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, reqdata, headers, _opts ->
      assert action == :patch

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:webhooks]}a/path?field=val"

      assert reqdata == Jason.encode!(data)
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Webhooks.request(:patch, "a/path", query, data, x_api_key: key)
  end

  test "default timeouts for all the requests" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, _endpoint, _data, _headers, opts ->
      assert action == :get
      assert opts[:hackney] == [pool: :default]
      assert opts[:timeout] == 60_000
      assert opts[:recv_timeout] == 60_000

      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.request(:get, "a/path", [], [], [])
  end

  test "passing a timeout option to a generic request" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, _endpoint, _data, _headers, opts ->
      assert action == :get
      assert opts[:hackney] == [pool: :default]
      assert opts[:recv_timeout] == 15_000

      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.request(:get, "a/path", [], [], [], recv_timeout: 15_000)
  end

  test "passing a timeout option to a users request" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, _headers, opts ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      assert opts[:recv_timeout] == 15_000

      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list([internal: true], [], recv_timeout: 15_000)
  end

  defp find_header(headers, header_key) do
    Enum.find(headers, fn {k, _v} ->
      k == header_key
    end)
  end

  describe "errors" do
    test "returns %AuthenticationError{} when the http client responds with 401" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:ok, %{body: ~s({"message": "Unauthorized"}), status_code: 401}}
      end)

      assert {:error,
              %BtrzExApiClient.AuthenticationError{
                code: "UNAUTHORIZED",
                message: "Unauthorized",
                status: 401
              }} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %InvalidRequestError{} when the http client responds with 400" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:ok, %{body: ~s({"code": "ANY_CODE", "message": "any message"}), status_code: 400}}
      end)

      assert {:error,
              %BtrzExApiClient.InvalidRequestError{
                code: "ANY_CODE",
                message: "any message",
                status: 400
              }} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %InvalidRequestError{} when the http client responds with 404" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:ok, %{body: ~s({"code": "NOT_FOUND", "message": "not found"}), status_code: 404}}
      end)

      assert {:error,
              %BtrzExApiClient.InvalidRequestError{
                code: "NOT_FOUND",
                message: "not found",
                status: 404
              }} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIError{} when the http client responds with 500" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:ok,
         %{body: ~s({"code": "INTERNAL_ERROR", "message": "internal error"}), status_code: 500}}
      end)

      assert {:error,
              %BtrzExApiClient.APIError{
                code: "INTERNAL_ERROR",
                message: "internal error",
                status: 500
              }} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIError{} when the http client responds with 500 and empty body" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:ok, %{body: "", status_code: 500}}
      end)

      assert {:error, %BtrzExApiClient.APIError{status: 500}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIConnectionError{} when the http client responds with {:error, _}" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers, _opts ->
        {:error, %{reason: "error!"}}
      end)

      assert {:error, %BtrzExApiClient.APIConnectionError{}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end
  end
end
