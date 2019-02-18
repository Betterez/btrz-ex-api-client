defmodule BtrzExApiClientTest do
  use ExUnit.Case, async: true
  doctest BtrzExApiClient
  import Mox

  test "list users with the correct params" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, _headers ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list()
  end

  test "list users with the correct params using internal token" do
    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      {"Authorization", bearer} = find_header(headers, "Authorization")
      assert bearer =~ ~r/Bearer \w/u
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(internal: true)
  end

  test "list users with the correct params using user token" do
    token =
      "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJidHJ6LWFwaS1jbGllbnQiLCJleHAiOjE1NTAyNDYzNjMsImlhdCI6MTU1MDI0NjI0MywiaXNzIjoiYnRyei1hcGktY2xpZW50IiwianRpIjoiYzE1OWRlZTktYzA3Yi00ZWVjLWFkYzEtZDlmMjE5ZmRlMDQzIiwibmJmIjoxNTUwMjQ2MjQyLCJzdWIiOnt9LCJ0eXAiOiJhY2Nlc3MifQ.Ca7SvDH5HZmjHA9uusIBw7cfP7RrKbMcNs_B9HHcIR_PZ5K9Hu3Y4L2BYhzUtwsojtoZmzmtXPM33IL7sCfPqw"

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, _data, headers ->
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
    |> expect(:request, fn action, endpoint, _data, headers ->
      assert action == :get
      assert endpoint == "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users"
      assert {"x-api-key", ^key} = find_header(headers, "x-api-key")
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.list(x_api_key: key)
  end

  test "import users with the correct params" do
    payload = [%{"id" => "1234bGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9", "email" => "test@betterez.com"}]

    BtrzExApiClient.HTTPClientMock
    |> expect(:request, fn action, endpoint, data, _headers ->
      assert action == :post

      assert endpoint ==
               "#{Application.get_env(:btrz_ex_api_client, :services)[:accounts]}users/import"

      assert Jason.decode!(data) == payload
      {:ok, %{body: "{}", status_code: 200}}
    end)

    BtrzExApiClient.Accounts.User.import(payload)
  end

  defp find_header(headers, header_key) do
    Enum.find(headers, fn {k, _v} ->
      k == header_key
    end)
  end

  describe "errors" do
    test "returns %AuthenticationError{} when the http client responds with 401" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:ok, %{body: ~s({"error": {"message": "unauthorized"}}), status_code: 401}}
      end)

      assert {:error, %BtrzExApiClient.AuthenticationError{}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %InvalidRequestError{} when the http client responds with 400" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:ok, %{body: ~s({"error": {"message": ""}}), status_code: 400}}
      end)

      assert {:error, %BtrzExApiClient.InvalidRequestError{}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %InvalidRequestError{} when the http client responds with 404" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:ok, %{body: ~s({"error": {"message": "not found"}}), status_code: 404}}
      end)

      assert {:error, %BtrzExApiClient.InvalidRequestError{}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIError{} when the http client responds with 500" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:ok, %{body: ~s({"error": {"message": "internal error"}}), status_code: 500}}
      end)

      assert {:error, %BtrzExApiClient.APIError{}} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIError{} when the http client responds with 500 and empty body" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:ok, %{body: "", status_code: 500}}
      end)

      assert {:error, %BtrzExApiClient.APIError{}} = BtrzExApiClient.request(:get, "", [], [], [])
    end

    test "returns %APIConnectionError{} when the http client responds with {:error, _}" do
      BtrzExApiClient.HTTPClientMock
      |> expect(:request, fn _action, _endpoint, _data, _headers ->
        {:error, %{reason: "error!"}}
      end)

      assert {:error, %BtrzExApiClient.APIConnectionError{}} =
               BtrzExApiClient.request(:get, "", [], [], [])
    end
  end
end
