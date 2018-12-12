defmodule ShiritorishiWeb.RoomChannel do
  use Phoenix.Channel
  alias ShiritorishiWeb.Presence
  import ShiritorishiWeb.Gettext

  def join("room:lobby", _message, socket) do
    send(self(), "after_join")
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"user" => user, "word" => word}, socket) do
    job_result = {:validate_and_insert, [user, word]} |> Honeydew.async(:my_queue, reply: true) |> Honeydew.yield
    case job_result do
      {:ok, {:ok, result}} ->
        broadcast!(socket, "new_msg", result)
        push(socket, "valid_word", %{})

      {:ok, {:error, event, message}} ->
        push(socket, event, %{data: message})

      nil ->
        push(socket, "error_job", %{data: gettext("job:error")})
    end

    {:noreply, socket}
  end

  def handle_in("fetch_public_replies", _payload, socket) do
    public_replies = :ets.lookup_element(:public_replies, "public_replies", 2)
    push(socket, "public_replies", %{data: public_replies})

    IO.inspect "pushed public replies"
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
    push(socket, "presence_state", Presence.list(socket))
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      online_at: inspect(System.system_time(:second))
    })
    {:noreply, socket}
  end
end
