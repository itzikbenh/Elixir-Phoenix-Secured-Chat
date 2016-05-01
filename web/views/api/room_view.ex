defmodule ChatSecured.Api.RoomView do
  use ChatSecured.Web, :view

  def render("index.json", %{rooms: rooms}) do
    %{rooms: render_many(rooms, ChatSecured.Api.RoomView, "room.json")}
  end

  def render("show.json", %{room: room}) do
    %{room: render_one(room, ChatSecured.Api.RoomView, "room.json")}
  end

  def render("room.json", %{room: room}) do
    %{id: room.id,
      name: room.name,
      user_id: room.user_id}
  end
end
