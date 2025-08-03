defmodule T2chatbackendWeb.AuthPlug do
  import Plug.Conn
  alias T2chatbackend.Auth.Supabase
  alias T2chatbackend.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, supa_user} <- Supabase.verify_token(token),
         {:ok, user} <- get_or_fetch_user(supa_user) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(401, "Unauthorized")
        |> halt()
    end
  end

  defp get_or_fetch_user(%{"sub" => supabase_user_id}) do
    case Accounts.get_user(supabase_user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
