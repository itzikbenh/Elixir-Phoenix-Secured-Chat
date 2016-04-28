defmodule ChatSecured.Router do
  use ChatSecured.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ChatSecured.Auth, repo: ChatSecured.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatSecured do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  #Other scopes may use custom stacks.
  scope "/api", ChatSecured.Api do
    pipe_through :api

    resources "/rooms", RoomController, except: [:new, :edit]
    resources "/users", UserController, except: [:new], param: "token"
    get "/verifytoken", UserController, :verify_token
    patch "/users/updatepassword/:token", UserController, :update_password
    resources "/sessions", SessionController, only: [:create]
  end
end
