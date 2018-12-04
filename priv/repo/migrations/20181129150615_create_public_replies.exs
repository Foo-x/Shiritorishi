defmodule Shiritorishi.Repo.Migrations.CreatePublicReplies do
  use Ecto.Migration

  def change do
    create table(:public_replies) do
      add :user, :string
      add :word, :string
      add :actual_last_char, :string
      add :upper_last_char, :string

      timestamps()
    end

  end
end
