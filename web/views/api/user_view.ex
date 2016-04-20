defmodule ChatSecured.Api.UserView do
  use ChatSecured.Web, :view
  alias ChatSecured.User


  def render("user.json", %{token: token, user: user}) do
    %{username: user.username, token: token}
  end

  def render("edit.json", %{user: user}) do
    %{email: user.email, username: user.username}
  end
end
