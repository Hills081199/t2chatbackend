defmodule T2chatbackend.CommonSpaces.CommonSpace do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :user_ids, :inserted_at, :updated_at]}
  schema "common_spaces" do
    field :user_ids, {:array, :string}

    has_many :posts, T2chatbackend.Posts.Post
    timestamps()
  end

  def changeset(common_space, attrs) do
    common_space
    |> cast(attrs, [:user_ids])
    |> validate_required([:user_ids])
    |> put_change(:user_ids, Enum.sort(attrs.user_ids || [])) # sort để tránh duplicate
  end
end
