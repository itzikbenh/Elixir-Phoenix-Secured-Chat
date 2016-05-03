defmodule ChatSecured.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "rooms:*", ChatSecured.RoomChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket

  @max_age 2 * 7 * 24 * 60 * 60
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user", token, max_age: @max_age) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _reason} ->
        :error
    end
  end

  #If something went wrong this function would return an error.
  def connect(_params, _socket), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #ChatSecured.Endpoint.broadcast("users_socket:#{socket.assigns.user_id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  #def id(_socket), do: nil
  def id(socket), do: "users_socket:#{socket.assigns.user_id}"
end
