defmodule Shiritorishi.PublicReply do
  use Ecto.Schema
  import Ecto.Changeset


  schema "public_replies" do
    field :user, :string
    field :word, :string

    timestamps()
  end

  @doc false
  def changeset(public_reply, attrs) do
    public_reply
    |> cast(attrs, [:user, :word])
    |> validate_required([:user, :word])
  end
end
