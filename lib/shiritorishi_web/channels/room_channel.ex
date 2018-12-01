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
    is_user_valid = user |> String.trim |> String.length |> (&(&1 != 0 and &1 <= 20)).()
    if !is_user_valid do
      push(socket, "invalid_user", %{})
    end

    last_char = :ets.lookup_element(:public_replies, "last_char", 2)
    is_word_valid = String.starts_with?(word, last_char) and (String.length word) >= 2
    if !is_word_valid do
      push(socket, "invalid_word", %{})
    end

    if is_user_valid and is_word_valid do
      case Repo.insert %PublicReply{user: user, word: word} do
        {:ok, _} ->
          :ets.insert(:public_replies, {"last_char", String.last(word)})
          broadcast!(socket, "new_msg", %{user: user, word: word})

        {:error, _} ->
          IO.inspect "!! something wrong with inserting reply !!"
      end
    end

    {:noreply, socket}
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
