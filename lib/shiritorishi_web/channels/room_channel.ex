defmodule ShiritorishiWeb.RoomChannel do
  use Phoenix.Channel
  alias ShiritorishiWeb.Presence
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply

  @public_replies_max_length 50

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

    public_replies = :ets.lookup_element(:public_replies, "public_replies", 2)
    last_char = public_replies
      |> List.first
      |> Map.get(:word)
      |> String.last
    is_word_valid = String.starts_with?(word, last_char)
      and (String.length word) >= 2
      and !String.ends_with? word, "ん"
    if !is_word_valid do
      push(socket, "invalid_word", %{})
    end

    if is_user_valid and is_word_valid do
      reply = %PublicReply{user: user, word: word}
      case Repo.insert reply do
        {:ok, _} ->
          new_public_replies = public_replies
            |> List.insert_at(0, reply)
            |> Enum.take(@public_replies_max_length)
          :ets.insert(:public_replies, {"public_replies", new_public_replies})
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
    public_replies = :ets.lookup_element(:public_replies, "public_replies", 2)
    json = ShiritorishiWeb.PublicReplyView.render("index.json", public_replies: public_replies)
    push(socket, "public_replies", json)

    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })
    {:noreply, socket}
  end
end
