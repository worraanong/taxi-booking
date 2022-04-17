defmodule TaxiWeb.UserController do
  use TaxiWeb, :controller
  alias Taxi.Repo
  alias Taxi.Accounts.User

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Register successfully.")
        |> redirect(to: Routes.session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

end
