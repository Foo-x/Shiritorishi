defmodule ShiritorishiWeb.RoomChannel.Worker do
  alias Shiritorishi.Repo
  alias Shiritorishi.PublicReply
  alias Shiritorishi.KanaDict
  import ShiritorishiWeb.Gettext

  @public_replies_max_length 50

  def validate_and_insert(user, word) do
    public_replies = :ets.lookup_element(:public_replies, "public_replies", 2)

    with {:ok} <- validate_user(user),
         {:ok} <- validate_word(word, public_replies)
    do
      actual_last_char = word
        |> KanaDict.strip_ignored
        |> String.last
      upper_last_char = KanaDict.to_upper actual_last_char
      reply = %PublicReply{
        user: user,
        word: word,
        actual_last_char: actual_last_char,
        upper_last_char: upper_last_char
      }
      case Repo.insert reply do
        {:ok, _} ->
          result = PublicReply.take_info(reply)
          new_public_replies = public_replies
            |> List.insert_at(0, result)
            |> Enum.take(@public_replies_max_length)
          :ets.insert(:public_replies, {"public_replies", new_public_replies})
          {:ok, result}

        {:error, _} ->
          IO.inspect "!! something wrong with inserting reply !!"
          {:error, "error_repo", gettext "db:error insert"}
      end
    else
      error_result ->
        error_result
    end
  end

  def validate_user(user) do
    is_user_valid = user |> String.trim |> String.length |> (&(&1 != 0 and &1 <= 20)).()
    if is_user_valid do
      {:ok}
    else
      {:error, "invalid_user", gettext "user:invalid"}
    end
  end

  def validate_word(word, public_replies) do
    words = public_replies
      |> Enum.map(&(Map.get(&1, :word)))

    last_char = public_replies
      |> List.first
      |> Map.get(:upper_last_char)

    error_tuple = {:error, "invalid_word"}

    cond do
      (String.length word) < 2 || (String.length word) > 20 ->
        Tuple.append(error_tuple, gettext "word:invalid length")

      !valid_first?(word, last_char) ->
        Tuple.append(error_tuple, gettext("word:invalid first", last_char: last_char))

      String.ends_with?(word, ["ん", "ン"]) ->
        Tuple.append(error_tuple, gettext "word:invalid last")

      !KanaDict.valid_text?(word) ->
        Tuple.append(error_tuple, gettext "word:invalid char")

      Enum.member?(words, word) ->
        Tuple.append(error_tuple, gettext("word:already used", word: word))

      true ->
        {:ok}
    end
  end

  def valid_first?(word, last_char) do
    first_char = String.first word
    KanaDict.to_hira(first_char) == KanaDict.to_hira(last_char)
  end
end
