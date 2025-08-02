defmodule T2chatbackend.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :supabase_user_id, :string, primary_key: true
      add :email, :string, null: false
      add :full_name, :string
      add :nickname, :string
      add :partner_id, :string
      timestamps()
    end

    # Thêm unique index để tránh user trùng (sau này sẽ cần)
    create unique_index(:users, [:supabase_user_id])
    create index(:users, [:partner_id])

  end
end
