defmodule T2chatbackendWeb.AuthController do
  use T2chatbackendWeb, :controller
  alias T2chatbackend.Auth.Supabase
  alias T2chatbackend.Accounts

  @doc """
  Đăng ký user: gọi Supabase + lưu vào DB
  """
  def register(conn, params) do
    with {:ok, %{"user" => supa_user}} <- Supabase.register_user(params),
         {:ok, user} <-
           Accounts.find_or_create(%{
             supabase_user_id: supa_user["id"],
             email: supa_user["email"],
             full_name: params["full_name"],
             nick_name: params["nick_name"]
           }) do
      json(conn, %{
        user: %{
          id: user.supabase_user_id,
          email: user.email,
          full_name: user.full_name,
          nick_name: user.nick_name
        }
      })
    else
      {:error, %{status: status, body: body}} ->
        conn
        |> put_status(status)
        |> json(%{error: body})

      {:error, "Email already registered"} ->
        conn
        |> put_status(400)
        |> json(%{error: "Email already registered"})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: inspect(reason)})
    end
  end

  @doc """
  Đăng nhập user: xác thực với Supabase + lấy thông tin từ DB
  """
  def login(conn, %{"email" => email, "password" => password} = params) do
    IO.inspect(password, label: "LOGIN")

    with {:ok,
          %{"access_token" => access_token, "refresh_token" => refresh_token, "user" => supa_user}} <-
           Supabase.login_user(params),
         {:ok, user} <- Accounts.find_by_supabase_id(supa_user["id"]) do
      json(conn, %{
        access_token: access_token,
        refresh_token: refresh_token,
        user: %{
          id: user.supabase_user_id,
          email: user.email,
          full_name: user.full_name,
          nick_name: user.nick_name
        }
      })
    else
      {:error, %{status: 400, message: message}} ->
        conn
        |> put_status(400)
        |> json(%{error: message})

      {:error, %{status: status, body: body}} ->
        conn
        |> put_status(status)
        |> json(%{error: body})

      {:error, :user_not_found} ->
        conn
        |> put_status(404)
        |> json(%{error: "User not found in database"})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: inspect(reason)})
    end
  end

  @doc """
  Đăng xuất user: hủy session với Supabase
  """
  def logout(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] ->
        case Supabase.logout_user(access_token) do
          {:ok, %{"message" => message}} ->
            json(conn, %{message: message})

          {:error, %{status: 401, message: message}} ->
            conn
            |> put_status(401)
            |> json(%{error: message})

          {:error, %{status: status, body: body}} ->
            conn
            |> put_status(status)
            |> json(%{error: body})

          {:error, reason} ->
            conn
            |> put_status(400)
            |> json(%{error: inspect(reason)})
        end

      _ ->
        conn
        |> put_status(401)
        |> json(%{error: "Authorization header required"})
    end
  end

  @doc """
  Làm mới access token
  """
  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case Supabase.refresh_token(refresh_token) do
      {:ok,
       %{
         "access_token" => access_token,
         "refresh_token" => new_refresh_token,
         "user" => supa_user
       }} ->
        case Accounts.find_by_supabase_id(supa_user["id"]) do
          {:ok, user} ->
            json(conn, %{
              access_token: access_token,
              refresh_token: new_refresh_token,
              user: %{
                id: user.supabase_user_id,
                email: user.email,
                full_name: user.full_name,
                nick_name: user.nick_name
              }
            })

          {:error, :user_not_found} ->
            conn
            |> put_status(404)
            |> json(%{error: "User not found in database"})
        end

      {:error, %{status: 401, message: message}} ->
        conn
        |> put_status(401)
        |> json(%{error: message})

      {:error, %{status: status, body: body}} ->
        conn
        |> put_status(status)
        |> json(%{error: body})

      {:error, reason} ->
        conn
        |> put_status(400)
        |> json(%{error: inspect(reason)})
    end
  end

  def refresh(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "refresh_token is required"})
  end

  @doc """
  Xác thực token và lấy thông tin user hiện tại
  """
  def me(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] ->
        case Supabase.verify_token(access_token) do
          {:ok, supa_user} ->
            case Accounts.find_by_supabase_id(supa_user["id"]) do
              {:ok, user} ->
                json(conn, %{
                  user: %{
                    id: user.supabase_user_id,
                    email: user.email,
                    full_name: user.full_name,
                    nick_name: user.nick_name
                  }
                })

              {:error, :user_not_found} ->
                conn
                |> put_status(404)
                |> json(%{error: "User not found in database"})
            end

          {:error, reason} ->
            conn
            |> put_status(401)
            |> json(%{error: reason})
        end

      _ ->
        conn
        |> put_status(401)
        |> json(%{error: "Authorization header required"})
    end
  end

  @doc """
  Kiểm tra tính hợp lệ của token (middleware helper)
  """
  def verify_token(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> access_token] ->
        case Supabase.verify_token(access_token) do
          {:ok, _user} ->
            json(conn, %{valid: true})

          {:error, _reason} ->
            conn
            |> put_status(401)
            |> json(%{valid: false, error: "Invalid token"})
        end

      _ ->
        conn
        |> put_status(401)
        |> json(%{valid: false, error: "Authorization header required"})
    end
  end
end
