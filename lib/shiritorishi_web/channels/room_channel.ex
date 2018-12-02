defmodule ShiritorishiWeb.RoomChannel do
  use Phoenix.Channel
  alias ShiritorishiWeb.Presence
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply
  alias Shiritorishi.KanaDict
  import ShiritorishiWeb.Gettext

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
    user_status =
      if is_user_valid do
        {:ok}
      else
        {:error, gettext "user:invalid"}
      end

    with {:error, message} <- user_status do
      push(socket, "invalid_user", %{data: message})
    end

    public_replies = :ets.lookup_element(:public_replies, "public_replies", 2)
    word_status = validate_word(word, public_replies)
    with {:error, message} <- word_status do
      push(socket, "invalid_word", %{data: message})
    end

    with {:ok} <- user_status,
         {:ok} <- word_status
    do
      reply = %PublicReply{user: user, word: word}
      case Repo.insert reply do
        {:ok, _} ->
          new_public_replies = public_replies
            |> List.insert_at(0, reply)
            |> Enum.take(@public_replies_max_length)
          :ets.insert(:public_replies, {"public_replies", new_public_replies})
          broadcast!(socket, "new_msg", %{user: user, word: word})
          push(socket, "valid_word", %{})

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

  def validate_word(word, public_replies) do
    words = public_replies
      |> Enum.map(&(Map.get(&1, :word)))

    last_char = words
      |> List.first
      |> KanaDict.strip_ignored
      |> String.last

    cond do
      (String.length word) < 2 ->
        {:error, gettext "word:invalid length"}

      !valid_first?(word, last_char) ->
        {:error, gettext("word:invalid first", last_char: last_char)}

      String.ends_with?(word, ["ん", "ン"]) ->
        {:error, gettext "word:invalid last"}

      !KanaDict.valid_text?(word) ->
        {:error, gettext "word:invalid char"}

      Enum.member?(words, word) ->
        {:error, gettext("word:already used", word: word)}

      true ->
        {:ok}
    end
  end

  def valid_first?(word, last_char) do
    first_char = String.first word
    KanaDict.to_hira(first_char) == KanaDict.to_hira(last_char)
  end
end
