defmodule ChatSecured.Api.MessageView do
  use ChatSecured.Web, :view

  def render("message.json", %{message: msg}) do
    %{
      body: msg.body,
      user: msg.user.username 
    }
  end
end
