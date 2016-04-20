defmodule ChatSecured.Api.SessionController do
  use ChatSecured.Web, :controller


  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do

    case ChatSecured.Auth.login_by_email_and_pass_api(conn, String.downcase(email), pass, repo: Repo) do
      {:ok, user, conn} ->
        conn
        |> put_status(:ok)
        |> render(ChatSecured.Api.UserView, "user.json", %{token: Phoenix.Token.sign(conn, "user", user.id), user: user})
      {:error, _reason, conn} ->
        conn
        |> put_status(:not_found)
        |> text("Invalid email/password combination")
    end
  end
end
