defmodule Taxi.Repo.Migrations.AddBookingTable do
  use Ecto.Migration

  def change do
    create table(:bookings) do
      add :pickup_address, :string
      add :dropoff_address, :string
      add :distance, :decimal
      add :status, :string, default: "OPEN"

      timestamps()
    end
  end
end
