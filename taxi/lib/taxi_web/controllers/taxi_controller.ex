defmodule TaxiWeb.TaxiController do
  use TaxiWeb, :controller
  alias Taxi.Repo
  alias Taxi.Accounts.User
  alias Taxi.Sales.{Taxi, Allocation, Booking}

  alias Ecto.{Changeset, Multi}
  import Ecto.Query, only: [from: 2]

  def index(conn, _params) do
    user = getCurrentUser(conn)
    query = from t in Taxi, where: t.user_id == ^user.id and t.active, select: t
    # for simplicity, let's assume one account has one Taxi
    taxi = Repo.one(query)
    if taxi != nil do
      bookings = getRideHistory(taxi.id)
      allot = getAllocation(taxi.id)
      if allot != nil do
        rideToComplete = getCurrentRide(allot.id)
        render(conn, "index.html", taxi: taxi, rideToComplete: rideToComplete, bookings: bookings)
      else
        render(conn, "index.html", taxi: taxi, rideToComplete: nil, bookings: bookings)
      end
    end

    render(conn, "index.html", taxi: taxi, rideToComplete: nil, bookings: nil)
  end

  def new(conn, _params) do
    changeset = Taxi.changeset(%Taxi{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"taxi" => taxi_params}) do
    user = getCurrentUser(conn)
    changeset = Taxi.changeset(%Taxi{}, taxi_params)
                |> Changeset.put_change(:user, user)
    case Repo.insert(changeset) do
      {:ok, taxi} ->
        conn
        |> put_flash(:info, "Register Taxi successfully")
        |> redirect(to: Routes.taxi_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    taxi = Repo.get!(Taxi, id)
    changeset = Taxi.changeset(taxi, %{})
    render(conn, "edit.html", taxi: taxi, changeset: changeset)
  end

  def update(conn, %{"id" => id, "taxi" => taxi_params}) do
    taxi = Repo.get!(Taxi, id)
    changeset = Taxi.changeset(taxi, taxi_params)

    Repo.update(changeset)
    conn
    |> put_flash(:info, "Taxi detail updated")
    |> redirect(to: Routes.taxi_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    taxi = Repo.get!(Taxi, id)
    # Repo.delete!(taxi)
    # History will gone, if we actually deleted the driver
      Multi.new
      |> Multi.update(:taxi, Taxi.changeset(taxi, %{}) |> Changeset.put_change(:active, false) |> Changeset.put_change(:status, "BUSY"))
      |> Repo.transaction

    conn
    |> put_flash(:info, "Your are not a Taxi driver anymore")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def completeRide(conn, %{"id" => id}) do
    user = getCurrentUser(conn)
    taxi = Repo.get(Taxi, id)

    if taxi != nil and taxi.user_id == user.id do
      allot = getAllocation(id)
      if allot != nil do
        Multi.new
        |> Multi.update(:allocation, Allocation.changeset(allot, %{}) |> Changeset.put_change(:status, "COMPLETED"))
        |> Multi.update(:taxi, Taxi.changeset(taxi, %{}) |> Changeset.put_change(:status, "AVAILABLE"))
        |> Repo.transaction
        conn
        |> put_flash(:info, "Completed ride")
        |> redirect(to: Routes.taxi_path(conn, :index))
      end
    end

    conn
      |> put_flash(:error, "You are not authourize to perform this action")
      |> redirect(to: Routes.page_path(conn, :index))
  end

  defp getCurrentUser(conn) do
    user = conn.assigns.current_user
    if user == nil do
      conn |> put_flash(:error, "Please login first")
           |> redirect(to: Routes.session_path(conn, :new))
    end
    user
  end

  defp getAllocation(id) do
    query = from a in Allocation,
      where: a.taxi_id == ^id and a.status == "ALLOCATED",
      order_by: [asc: :inserted_at],
      select: a
    Repo.all(query) |> List.first
  end

  defp getRideHistory(id) do
    query = from b in Booking,
      join: a in Allocation, on: a.booking_id == b.id and a.taxi_id == ^id,
      left_join: u in User, on: u.id == b.user_id,
      order_by: [asc: :inserted_at],
      select: b
    Repo.all(query) |> Repo.preload(:user)
  end

  defp getCurrentRide(id) do
    query = from b in Booking,
      join: a in Allocation, on: a.booking_id == b.id and a.id == ^id,
      left_join: u in User, on: u.id == b.user_id,
      order_by: [asc: :inserted_at],
      select: b
    Repo.one(query) |> Repo.preload(:user)
  end

end
