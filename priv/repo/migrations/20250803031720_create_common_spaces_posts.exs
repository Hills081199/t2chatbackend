defmodule T2chatbackend.Repo.Migrations.CreateCommonSpacesPosts do
  use Ecto.Migration

  def change do
    # Bảng common_spaces
    create table(:common_spaces, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_ids, {:array, :string}, null: false
      timestamps()
    end

    # Đảm bảo không tạo 2 common_space cho cùng 1 cặp user
    # (cần sort user_ids trước khi insert để index hiệu quả)
    create unique_index(:common_spaces, [:user_ids])

    # Bảng posts
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :common_space_id, references(:common_spaces, type: :binary_id, on_delete: :delete_all)
      add :user_id, :string, null: false    # người tạo post
      add :general_content, :text
      timestamps()
    end

    create index(:posts, [:common_space_id])

    # Bảng post_images
    create table(:post_images, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :post_id, references(:posts, type: :binary_id, on_delete: :delete_all)
      add :image_url, :string, null: false
      add :image_content, :text
      timestamps()
    end

    create index(:post_images, [:post_id])
  end
end
