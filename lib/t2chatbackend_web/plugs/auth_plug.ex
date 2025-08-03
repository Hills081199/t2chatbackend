defmodule T2chatbackendWeb.AuthPlug do
  import Plug.Conn
  alias T2chatbackend.Auth.Supabase
  alias T2chatbackend.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, supa_user} <- Supabase.verify_token(token),
         {:ok, user} <- get_or_fetch_user(supa_user["id"]) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  defp get_or_fetch_user(supabase_user_id) do
    case Accounts.find_by_supabase_id(supabase_user_id) do
      nil ->
        # If user doesn't exist, you might want to create them here
        # or return an error depending on your requirements
        {:error, :user_not_found}
      user ->
        {:ok, user}
    end
  end
end
