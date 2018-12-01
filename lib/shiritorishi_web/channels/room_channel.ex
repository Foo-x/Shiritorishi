defmodule ShiritorishiWeb.RoomChannel do
  use Phoenix.Channel
  alias ShiritorishiWeb.Presence
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply
  import Ecto.Query, only: [order_by: 2, limit: 2]

  def join("room:lobby", _message, socket) do
    send(self(), "after_join")
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"user" => user, "word" => word}, socket) do
    last_char = :ets.lookup_element(:public_replies, "last_char", 2)
    if String.starts_with?(word, last_char) do
      broadcast!(socket, "new_msg", %{user: user, word: word})
      :ets.insert(:public_replies, {"last_char", String.last(word)})
      {:noreply, socket}
    else
      push(socket, "invalid_word", %{})
      {:noreply, socket}
    end
  end

  intercept ["presence_diff"]

  def handle_out("presence_diff", payload, socket) do
    push(socket, "presence_diff", Map.put(payload,
      :user_count, Presence.list(socket) |> map_size
    ))
    {:noreply, socket}
  end

  def handle_info("after_join", socket) do
    public_replies = PublicReply
      |> order_by([desc: :id])
      |> limit(50)
      |> Repo.all
      |> Enum.sort_by(&(&1.id), &>=/2)
    json = ShiritorishiWeb.PublicReplyView.render("index.json", public_replies: public_replies)
    push(socket, "public_replies", json)

    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })
    {:noreply, socket}
  end
end
