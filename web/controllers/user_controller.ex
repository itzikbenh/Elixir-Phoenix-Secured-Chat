defmodule ChatSecured.UserController do
  use ChatSecured.Web, :controller
  plug :authenticate_user when action in [:index, :show]

  alias ChatSecured.User

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  #Through pattern matching we will fetch the ID param
  #In this case on ID "1" it will be ->  %{"id" => id} = %{"id" =>  "1"} which will make id=1
  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  #This is how the parameters might look like
  #"user" => %{"name" => "Johnny", "password" => "[FILTERED]", "username" => "JohnnyCage"}}
  def create(conn, %{"user" => user_params}) do
    IO.inspect user_params
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> ChatSecured.Auth.login(user)
        |> put_flash(:info, "#{user.username} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
