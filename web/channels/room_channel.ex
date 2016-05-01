defmodule ChatSecured.RoomChannel do
  use ChatSecured.Web, :channel
  alias ChatSecured.Api.MessageView

  def join("rooms:" <> room_name, _params, socket) do
    #video_id = String.to_integer(video_id)
    room = Repo.get_by!(ChatSecured.Room, name: room_name)

    messages = Repo.all(
      from a in assoc(room, :messages),
        order_by: [asc: a.inserted_at],
        limit: 200,
        preload: [:user]
    )

    resp = %{messages: Phoenix.View.render_many(messages, MessageView, "message.json")}
    {:ok, resp, assign(socket, :room_id, room.id)}
  end


  def handle_in("disconnect", _params, socket) do
    ChatSecured.Endpoint.broadcast("users_socket:#{socket.assigns.user_id}", "disconnect", %{})
    {:noreply, socket}
  end

  def handle_in("new_msg", params, socket) do
    user = ChatSecured.Repo.get(ChatSecured.User, socket.assigns.user_id)

    changeset =
      user
      |> build_assoc(:messages, room_id: socket.assigns.room_id)
      |> ChatSecured.Message.changeset(params)

    case Repo.insert(changeset) do
      {:ok, message} ->
        broadcast! socket, "new_msg", %{
          #id: annotation.id,
          user: ChatSecured.Api.UserView.render("usersocket.json", %{user: user}),
          body: message.body,
        }
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

end
