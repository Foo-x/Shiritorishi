defmodule Shiritorishi.PublicReply do
  use Ecto.Schema
  import Ecto.Changeset


  schema "public_replies" do
    field :user, :string
    field :word, :string
    field :actual_last_char, :string
    field :upper_last_char, :string

    timestamps()
  end

  @doc false
  def changeset(public_reply, attrs) do
    public_reply
    |> cast(attrs, [:user, :word, :actual_last_char, :upper_last_char])
    |> validate_required([:user, :word, :actual_last_char, :upper_last_char])
  end

  def take_info(public_reply) do
    public_reply
      |> Map.from_struct
      |> Map.take([:user, :word, :actual_last_char, :upper_last_char])
  end
end
