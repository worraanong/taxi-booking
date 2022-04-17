defmodule TaxiWeb.BookingControllerTest do
  use TaxiWeb.ConnCase
  alias Taxi.{Repo, Sales.Taxi, Sales.Booking}

  test "Booking accepted", %{conn: conn} do
    Repo.insert!(%Taxi{status: "AVAILABLE"})
    conn = post conn, "/bookings", %{booking: [pickup_address: "Liivi 2", dropoff_address: "Lõunakeskus", distance: 1]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/Your taxi will arrive in \d+ minutes/
  end

  test "Booking rejected", %{conn: conn} do
    conn = get build_conn(), "/"
    Repo.insert!(%Taxi{status: "BUSY"})
    conn = post conn, "/bookings", %{booking: [pickup_address: "Liivi 2", dropoff_address: "Lõunakeskus", distance: 1]}
    conn = get conn, redirected_to(conn)
    assert html_response(conn, 200) =~ ~r/At present, there is no taxi available!/
  end

  test "Pickup and dropoff addresses must different", %{conn: conn} do
    changeset = Booking.changeset(%Booking{}, %{pickup_address: "Liivi 2", dropoff_address: "Liivi 2"})
    assert Keyword.has_key? changeset.errors, :dropoff_address
  end

end
