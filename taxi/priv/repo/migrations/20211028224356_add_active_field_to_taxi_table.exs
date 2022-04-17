defmodule Taxi.Repo.Migrations.AddActiveFieldToTaxiTable do
  use Ecto.Migration

  def change do
    alter table(:taxis) do
      add :active, :boolean, default: true
    end
  end
end
