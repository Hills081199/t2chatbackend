defmodule T2chatbackend.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :user_id, :common_space_id, :general_content, :images, :inserted_at, :updated_at]}
  schema "posts" do
    field :user_id, :string
    field :general_content, :string
    belongs_to :common_space, T2chatbackend.CommonSpaces.CommonSpace, type: :binary_id
    has_many :images, T2chatbackend.Posts.PostImage, on_replace: :delete
    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:user_id, :common_space_id, :general_content])
    |> validate_required([:user_id, :common_space_id, :general_content])
    |> cast_assoc(:images, with: &T2chatbackend.Posts.PostImage.changeset/2)
  end
end
