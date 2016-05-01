defmodule ChatSecured.Api.UserView do
  use ChatSecured.Web, :view
  alias ChatSecured.User

  def render("user.json", %{token: token, user: user}) do
    %{username: user.username, email: user.email, token: token}
  end

  def render("usersocket.json", %{user: user}) do
    %{username: user.username}
  end

  def render("edit.json", %{user: user}) do
    %{email: user.email, username: user.username}
  end

  def render("update.json", %{user: user}) do
    %{username: user.username, email: user.email, flash: "Account has been updated successfully"}
  end

  def render("update_password.json", %{user: user}) do
    %{username: user.username, flash: "Password has been updated successfully"}
  end
end
