defmodule T2chatbackend.Accounts do
  import Ecto.Query
  alias T2chatbackend.Repo
  alias T2chatbackend.Accounts.User

  def get_user!(supabase_user_id), do: Repo.get!(User, supabase_user_id)

  def find_or_create(attrs) do
    case Repo.get_by(User, email: attrs.email) do
      nil ->
        # Nếu email chưa có -> tạo mới
        create_user(attrs)

      user ->
        # Nếu email đã tồn tại -> trả về user luôn
        {:error, "Email already registered"}
    end
  end


  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def get_user!(supabase_user_id), do: Repo.get!(User, supabase_user_id)

  def find_by_supabase_id(supabase_user_id) do
    case Repo.get(User, supabase_user_id) do
      nil -> {:error, :user_not_found}
      user -> {:ok, user}
    end
  end
end
