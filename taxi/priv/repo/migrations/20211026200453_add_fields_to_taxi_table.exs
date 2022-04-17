defmodule Taxi.Repo.Migrations.AddFieldsToTaxiTable do
  use Ecto.Migration

  def change do
    alter table(:taxis) do
      add :total_seat, :integer
      add :cost_per_kilo, :decimal
      add :user_id, references(:users)
    end
  end
end
