defmodule T2chatbackendWeb.InviteController do
  use T2chatbackendWeb, :controller
  alias T2chatbackend.Invites

  plug T2chatbackendWeb.AuthPlug

  # Lấy tất cả invite của user hiện tại
  def index(conn, _params) do
    {:ok, user} = conn.assigns.current_user
    invites = Invites.list_invites_for_email(user.email)
    json(conn, invites)
  end

  # Tạo invite
  def create(conn, %{"email" => invitee_email}) do
    {:ok, user} = conn.assigns.current_user

    case Invites.create_invite(user.supabase_user_id, invitee_email) do
      {:ok, invite} ->
        json(conn, invite)

      {:error, :user_not_found} ->
        conn |> put_status(404) |> json(%{error: "User with email not found"})

      {:error, :self_invite} ->
        conn |> put_status(404) |> json(%{error: "Cannot self invite"})

      {:error, :invite_pending} ->
        conn |> put_status(400) |> json(%{error: "You have already invited this user"})

      {:error, :already_connected} ->
        conn |> put_status(400) |> json(%{error: "You are already connected with this user"})

      {:error, changeset} ->
        conn |> put_status(400) |> json(changeset)
    end
  end

  # Accept invite
  def accept(conn, %{"id" => invite_id}) do
    {:ok, user} = conn.assigns.current_user

    case Invites.accept_invite(invite_id, user.supabase_user_id) do
      {:ok, space} -> json(conn, space)
      {:error, :not_found} -> send_resp(conn, 404, "Not found")
      {:error, :unauthorized} -> send_resp(conn, 403, "Forbidden")
    end
  end

  # Reject invite
  def reject(conn, %{"id" => invite_id}) do
    {:ok, user} = conn.assigns.current_user

    case Invites.reject_invite(invite_id, user.supabase_user_id) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, :not_found} -> send_resp(conn, 404, "Not found")
      {:error, :unauthorized} -> send_resp(conn, 403, "Forbidden")
    end
  end
end
