defmodule Twix.Repo.Migrations.CreateFollowersTable do
  use Ecto.Migration

  def up do
    create table(:followers, primary_key: false) do
      add(:follower_id, references(:users, on_delete: :delete_all))
      add(:following_id, references(:users, on_delete: :delete_all))
    end

    create unique_index(:followers, [:follower_id, :following_id])
  end

  def down do
    drop unique_index(:followers, [:follower_id, :following_id])
    drop table(:followers)
  end
end
