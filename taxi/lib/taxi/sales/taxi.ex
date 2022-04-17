defmodule Taxi.Sales.Taxi do
  use Ecto.Schema
  import Ecto.Changeset

  schema "taxis" do
    field :location, :string
    field :status, :string
    field :total_seat, :integer
    field :cost_per_kilo, :decimal
    belongs_to :user, Taxi.Accounts.User
    field :active, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(taxi, attrs) do
    taxi
    |> cast(attrs, [:location, :status, :total_seat, :cost_per_kilo])
    |> validate_required([:location, :status])
  end
end
