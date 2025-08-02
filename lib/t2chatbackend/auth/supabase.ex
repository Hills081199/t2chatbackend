defmodule T2chatbackend.Auth.Supabase do
  @moduledoc """
  Xác thực token với supabase
  """
  defp supabase_url do
    config = Application.get_env(:t2chatbackend, :supabase, [])
    url = Keyword.get(config, :supabase_url, "")
    url
  end

  defp supabase_service_key do
    config = Application.get_env(:t2chatbackend, :supabase, [])
    key = Keyword.get(config, :supabase_service_key, "")
    key
  end

  def verify_token(token) do
    headers = [
      {"Authorization", "Bearer #{token}"},
      {"apiKey", supabase_service_key()}
    ]
    url = "#{supabase_url()}/auth/v1/user"

    case Finch.build(:get, url, headers) |> Finch.request(T2chatbackend.Finch) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %{status: status}} ->
        {:error, "Invalid token (#{status})"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def register_user(%{"email" => email, "password" => password} = params) do
    url = "#{supabase_url()}/auth/v1/signup"
    headers = [
      {"Authorization", "Bearer #{supabase_service_key()}"},
      {"apikey", supabase_service_key()},
      {"content-type", "application/json"}
    ]
    data = %{
      full_name: params["full_name"],
      nickname: params["nick_name"]
    }
    # Prepare the request body with proper Supabase signup structure
    body = %{
      email: email,
      password: password,
      data: data
    } |> Jason.encode!()

    case Finch.build(:post, url, headers, body) |> Finch.request(T2chatbackend.Finch) do
      {:ok, %{status: 200, body: body}} ->
        response = Jason.decode!(body)
        {:ok, %{
          "user" => %{
            "id" => response["id"],
            "email" => response["email"],
            "user_metadata" => response["user_metadata"] || %{}
          }
        }}

      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def login_user(%{"email" => email, "password" => password}) do
    IO.inspect(email, label: "EMAIL")
    IO.inspect(password, label: "PASSWORD")
    url = "#{supabase_url()}/auth/v1/token?grant_type=password"
    headers = [
      {"Authorization", "Bearer #{supabase_service_key()}"},
      {"apikey", supabase_service_key()},
      {"content-type", "application/json"}
    ]
    body = %{
      email: email,
      password: password
    } |> Jason.encode!()

    case Finch.build(:post, url, headers, body) |> Finch.request(T2chatbackend.Finch) do
      {:ok, %{status: 200, body: body}} ->
        response = Jason.decode!(body)
        {:ok, %{
          "access_token" => response["access_token"],
          "refresh_token" => response["refresh_token"],
          "expires_in" => response["expires_in"],
          "token_type" => response["token_type"],
          "user" => %{
            "id" => response["user"]["id"],
            "email" => response["user"]["email"],
            "user_metadata" => response["user"]["user_metadata"] || %{}
          }
        }}
      {:ok, %{status: 400, body: body}} ->
        error_response = Jason.decode!(body)
        {:error, %{status: 400, message: error_response || "Invalid credentials"}}
      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def logout_user(access_token) do
    url = "#{supabase_url()}/auth/v1/logout"
    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"apikey", supabase_service_key()},
      {"content-type", "application/json"}
    ]

    case Finch.build(:post, url, headers, "{}") |> Finch.request(T2chatbackend.Finch) do
      {:ok, %{status: 204}} ->
        {:ok, %{"message" => "Successfully logged out"}}
      {:ok, %{status: 401}} ->
        {:error, %{status: 401, message: "Invalid or expired token"}}
      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  def refresh_token(refresh_token) do
    url = "#{supabase_url()}/auth/v1/token?grant_type=refresh_token"
    headers = [
      {"Authorization", "Bearer #{supabase_service_key()}"},
      {"apikey", supabase_service_key()},
      {"content-type", "application/json"}
    ]

    body = %{
      refresh_token: refresh_token
    } |> Jason.encode!()

    case Finch.build(:post, url, headers, body) |> Finch.request(T2chatbackend.Finch) do
      {:ok, %{status: 200, body: body}} ->
        response = Jason.decode!(body)
        {:ok, %{
          "access_token" => response["access_token"],
          "refresh_token" => response["refresh_token"],
          "expires_in" => response["expires_in"],
          "token_type" => response["token_type"],
          "user" => response["user"]
        }}
      {:ok, %{status: 401}} ->
        {:error, %{status: 401, message: "Invalid refresh token"}}
      {:ok, %{status: status, body: body}} ->
        {:error, %{status: status, body: Jason.decode!(body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
