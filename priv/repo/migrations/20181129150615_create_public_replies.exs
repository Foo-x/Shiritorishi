defmodule Shiritorishi.Repo.Migrations.CreatePublicReplies do
  use Ecto.Migration

  def change do
    create table(:public_replies) do
      add :user, :string
      add :word, :string

      timestamps()
    end

  end
end
