defmodule T2chatbackend.Invites do
  import Ecto.Query
  alias T2chatbackend.Repo
  alias T2chatbackend.Invites.Invite
  alias T2chatbackend.Accounts
  alias T2chatbackend.CommonSpaces

  def list_invites do
    Invite
    |> Repo.all()
  end

  def list_invites_for_email(email) do
    from(i in Invite, where: i.invitee_email == ^email and i.status == "pending")
    |> Repo.all()
  end


  def create_invite(inviter_id, invitee_email) do
    case T2chatbackend.Accounts.get_user_by_email(invitee_email) do
      nil ->
        {:error, :user_not_found}

      invitee ->
        inviter = T2chatbackend.Accounts.get_user!(inviter_id)

        # Kiểm tra có invite pending (2 chiều)
        pending_invite = Repo.exists?(
          from i in T2chatbackend.Invites.Invite,
          where:
            (i.inviter_id == ^inviter_id and i.invitee_email == ^invitee_email and i.status == "pending") or
            (i.inviter_id == ^invitee.supabase_user_id and i.invitee_email == ^inviter.email and i.status == "pending")
        )

        # Kiểm tra đã có common_space
        existing_space = T2chatbackend.CommonSpaces.get_space_by_users(inviter_id, invitee.supabase_user_id)

        cond do
          # Không cho phép invite bản thân
          inviter_id == invitee.supabase_user_id ->
            {:error, :self_invite}

          # Có invite pending
          pending_invite ->
            {:error, :invite_pending}

          # Đã có connection
          existing_space != nil ->
            {:error, :already_connected}

          # Tạo invite mới
          true ->
            %Invite{}
            |> Invite.changeset(%{inviter_id: inviter_id, invitee_email: invitee_email})
            |> Repo.insert()
        end
    end
  end

  def accept_invite(invite_id, current_user_id) do
    case Repo.get(Invite, invite_id) do
      nil ->
        {:error, :not_found}

      %Invite{invitee_email: email, inviter_id: inviter_id} = invite ->
        # Kiểm tra người accept có đúng người được mời không
        user = Accounts.get_user!(current_user_id)

        if user.email == email do
          # Tạo common space
          {:ok, space} = CommonSpaces.create_space(inviter_id, current_user_id)
          # Xóa invite
          Repo.delete(invite)
          {:ok, space}
        else
          {:error, :unauthorized}
        end
    end
  end

  def reject_invite(invite_id, current_user_id) do
    case Repo.get(Invite, invite_id) do
      nil -> {:error, :not_found}
      %Invite{invitee_email: email} = invite ->
        user = Accounts.get_user!(current_user_id)
        if user.email == email do
          Repo.delete(invite)
        else
          {:error, :unauthorized}
        end
    end
  end

end
