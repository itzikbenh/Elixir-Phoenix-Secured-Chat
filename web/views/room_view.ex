defmodule ChatSecured.RoomView do
  use ChatSecured.Web, :view

  def render("index.json", %{rooms: rooms}) do
    %{data: render_many(rooms, ChatSecured.RoomView, "room.json")}
  end

  def render("show.json", %{room: room}) do
    %{data: render_one(room, ChatSecured.RoomView, "room.json")}
  end

  def render("room.json", %{room: room}) do
    %{id: room.id,
      name: room.name,
      user_id: room.user_id}
  end
end
