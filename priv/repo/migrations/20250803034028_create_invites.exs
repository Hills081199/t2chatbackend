defmodule T2chatbackend.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :inviter_id, :string, null: false      # người gửi
      add :invitee_email, :string, null: false   # email người được mời
      add :status, :string, default: "pending"   # pending, accepted, rejected
      timestamps()
    end

    create index(:invites, [:invitee_email])
  end
end
