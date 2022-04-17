defmodule Taxi.Sales.Allocation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "allocations" do
    field :status, :string
    belongs_to :booking, Takso.Sales.Booking
    belongs_to :taxi, Takso.Sales.Taxi

    timestamps()
  end

  @doc false
  def changeset(allocation, attrs) do
    allocation
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end
