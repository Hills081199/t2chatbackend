defmodule T2chatbackend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:supabase_user_id, :email, :full_name, :nick_name, :partner_id, :inserted_at, :updated_at]}
  @primary_key {:supabase_user_id, :string, []}
  schema "users" do
    field :email, :string
    field :full_name, :string
    field :nick_name, :string
    field :partner_id, :string
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:supabase_user_id, :email, :full_name, :nick_name, :partner_id])
    |> validate_required([:supabase_user_id, :email])
    |> unique_constraint(:email)
  end
end
