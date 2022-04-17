defmodule TaxiWeb.BookingController do
  use TaxiWeb, :controller

  alias Taxi.{Repo, Accounts.User}
  alias Taxi.Sales.{Booking, Allocation}

  import Ecto.Query, only: [from: 2]
  alias Ecto.{Changeset, Multi}

  def index(conn, _params) do
    user = getCurrentUser(conn)
    query = from b in Booking, where: b.user_id == ^user.id, order_by: [asc: :inserted_at], select: b
    bookings = Repo.all(query)
    render(conn, "index.html", bookings: bookings)
  end

  def new(conn, _params) do
    changeset = Booking.changeset(%Booking{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn,  %{"booking" => booking_params}) do
    user = getCurrentUser(conn)

    query = from t in Taxi.Sales.Taxi,
      left_join: a in Allocation, on: t.id == a.taxi_id and a.status == "COMPLETED",
      where: t.status == "AVAILABLE" and t.active,
      group_by: t.id,
      order_by: :cost_per_kilo,
      select:  %{taxi_details: t, completed_ride: fragment("count(?) as completed_ride", a.id)} ,
      order_by: fragment("completed_ride")

    available_taxis = Repo.all(query)
    available = length(available_taxis) > 0

    changeset = updateBookingStatus(available, booking_params, user)
    type = if available, do: :info, else: :error
    msg = if available, do: "Your taxi will arrive in 5 minutes", else: "At present, there is no taxi available!"

    booking = Repo.insert(changeset)
    case booking do
      {:ok, changeset} ->
        if available do
          taxi = List.first(available_taxis).taxi_details
          Multi.new
          |> Multi.insert(:allocation, Allocation.changeset(%Allocation{}, %{status: "ALLOCATED"})
            |> Changeset.put_change(:taxi_id, taxi.id)
            |> Changeset.put_change(:booking_id, changeset.id)
          )
          |> Multi.update(:taxi, Taxi.Sales.Taxi.changeset(taxi, %{}) |> Changeset.put_change(:status, "BUSY"))
          |> Repo.transaction
        end
        conn |> put_flash(type, msg)
             |> redirect(to: Routes.booking_path(conn, :show, changeset))
      {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    booking = Repo.get!(Booking, id)
    query = from a in Allocation,
      join: t in Taxi.Sales.Taxi, on: t.id == a.taxi_id and a.booking_id == ^id,
      left_join: u in User, on: u.id == t.user_id,
      select: t
    taxi = Repo.one(query) |> Repo.preload(:user)
    render(conn, "info.html", booking: booking, taxi: taxi)
  end

  defp updateBookingStatus(available, booking_params, user) do
    st = if available, do: "ACCEPTED", else: "REJECTED"

    Booking.changeset(%Booking{}, booking_params)
                |> Changeset.put_change(:status, st)
                |> Changeset.put_change(:user, user)
  end

  defp getCurrentUser(conn) do
    user = conn.assigns.current_user
    if user == nil do
      conn |> put_flash(:error, "Please login first")
           |> redirect(to: Routes.session_path(conn, :new))
    end
    user
  end

end
