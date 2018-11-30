defmodule ShiritorishiWeb.RoomChannel do
  use Phoenix.Channel
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply

  def join("room:lobby", _message, socket) do
    send(self(), "public_replies")
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"user" => user, "word" => word}, socket) do
    broadcast!(socket, "new_msg", %{user: user, word: word})
    {:noreply, socket}
  end

  def handle_info("public_replies", socket) do
    public_replies = Repo.all(PublicReply)
    json = ShiritorishiWeb.PublicReplyView.render("index.json", public_replies: public_replies)
    push(socket, "public_replies", json)
    {:noreply, socket}
  end
end
