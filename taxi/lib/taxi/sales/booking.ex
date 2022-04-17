defmodule Taxi.Sales.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bookings" do
    field :dropoff_address, :string
    field :pickup_address, :string
    field :distance, :decimal
    field :status, :string, default: "OPEN"
    belongs_to :user, Taxi.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:pickup_address, :dropoff_address, :distance, :status])
    |> validate_required([:pickup_address, :dropoff_address, :distance])
    |> validate_number(:distance, greater_than_or_equal_to: 0)
    |> validate_dropoff()
  end


  defp validate_dropoff(changeset) do
    pickup = get_field(changeset, :pickup_address)
    dropoff = get_field(changeset, :dropoff_address)
    if pickup == dropoff do
      add_error(changeset, :dropoff_address, "Pickup and Dropoff addresses cannot be the same")
    else
      changeset
    end
  end

end
