defmodule TaxiWeb.SessionController do
  use TaxiWeb, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Taxi.Authentication.check_credentials(conn, email, password, repo: Taxi.Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome #{email}")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Bad credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> Taxi.Authentication.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end

end
