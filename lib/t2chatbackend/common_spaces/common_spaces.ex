defmodule T2chatbackend.CommonSpaces do
  import Ecto.Query
  alias T2chatbackend.Repo
  alias T2chatbackend.CommonSpaces.CommonSpace

  # Lấy tất cả common_space của 1 user
  def list_user_spaces(user_id) do
    from(cs in CommonSpace,
      where: ^user_id in cs.user_ids
    )
    |> Repo.all()
  end

  # Tìm 1 common_space theo cặp user_ids (dùng khi tạo)
  def get_space_by_users(user1, user2) do
    sorted = Enum.sort([user1, user2])

    from(cs in CommonSpace,
      where: cs.user_ids == ^sorted
    )
    |> Repo.one()
  end

  # Tạo common_space cho 2 user
  def create_space(user1, user2) do
    sorted = Enum.sort([user1, user2])

    case get_space_by_users(user1, user2) do
      nil ->
        %CommonSpace{}
        |> CommonSpace.changeset(%{user_ids: sorted})
        |> Repo.insert()

      space ->
        {:ok, space}
    end
  end

  # Xoá common_space (chỉ user trong space mới có quyền)
  def delete_space(space_id, user_id) do
    case Repo.get(CommonSpace, space_id) do
      nil ->
        {:error, :not_found}

      %CommonSpace{user_ids: user_ids} = space ->
        if user_id in user_ids do
          Repo.delete(space)
        else
          {:error, :unauthorized}
        end
    end
  end
end
