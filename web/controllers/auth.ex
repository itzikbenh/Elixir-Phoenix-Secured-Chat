#This is a module Plug
#Module Plugs provides two functions with some configuration details.
#A typical Plug transofrms a collection
defmodule ChatSecured.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  #Happens at compile time. Plug will use the result of init as the second argument to call.
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end
  #On every request the current_user is either set to the user or to nil.
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)
    cond do
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)
      user = user_id && repo.get(ChatSecured.User, user_id) ->
        put_current_user(conn, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    #Tell Plug to send the session cookie back to the client with a different identifier.
    #in case an attacker knew the previous one
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
  @max_age 2 * 7 * 24 * 60 * 60 # 14 days
  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    IO.inspect Phoenix.Token.verify(conn, "user socket", token, max_age: @max_age)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(ChatSecured.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  #Serves API login request
  def login_by_email_and_pass_api(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(ChatSecured.User, email: email)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, user, conn}
      user ->
        {:error, :unauthorized, conn}
      true ->
        #Fake check if there is no user so it will return "not found"
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  #validate_password on request to update password
  def validate_password(conn, user, given_pass) do
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, user, conn}
      user ->
        {:error, :unauthorized, conn}
      true ->
        #Fake check if there is no user so it will return "not found"
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  import Phoenix.Controller
  alias ChatSecured.Router.Helpers

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  #If token is older than 14 days then verification would fail with reason-expired.
  @max_age 2 * 7 * 24 * 60 * 60 # 14 days

  def verify_token_and_set_user(conn, _opts) do
    token = conn.params["token"]
    #Returns status :ok and the users ID on successful token verification
    case Phoenix.Token.verify(conn, "user", token, max_age: @max_age) do
      {:ok, user_id} ->
        cond do
          user = ChatSecured.Repo.get(ChatSecured.User, user_id) ->
            conn
            |> assign(:current_user, user)
          true ->
            conn
            |> put_status(:not_found)
            |> text("User not found")
            |> halt() #We wnat to stop everything on error. Otherwise it will to the action which is bad.
        end
      {:error, _reason} ->
        conn
        |> put_status(:not_acceptable)
        |> text("token failed verification")
        |> halt() #We wnat to stop everything on error. Otherwise it will to the action which is bad.
    end
  end
end
