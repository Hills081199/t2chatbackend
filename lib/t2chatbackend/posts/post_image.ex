defmodule T2chatbackend.Posts.PostImage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :image_url, :image_content]}
  schema "post_images" do
    field :image_url, :string
    field :image_content, :string
    belongs_to :post, T2chatbackend.Posts.Post, type: :binary_id
    timestamps()
  end

  def changeset(post_image, attrs) do
    post_image
    |> cast(attrs, [:image_url, :image_content, :post_id])
    |> validate_required([:image_url])
  end
end
