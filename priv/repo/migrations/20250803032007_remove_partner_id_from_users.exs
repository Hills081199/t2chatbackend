defmodule T2chatbackend.Repo.Migrations.RemovePartnerIdFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :partner_id
    end
  end
end
