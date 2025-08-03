defmodule T2chatbackend.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :inviter_id, :invitee_email, :status, :inserted_at]}
  schema "invites" do
    field :inviter_id, :string
    field :invitee_email, :string
    field :status, :string, default: "pending"
    timestamps()
  end

  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:inviter_id, :invitee_email, :status])
    |> validate_required([:inviter_id, :invitee_email])
  end
end
