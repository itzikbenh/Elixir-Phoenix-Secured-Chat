defmodule ChatSecured.UserView do
  use ChatSecured.Web, :view
  alias ChatSecured.User


  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end
end
