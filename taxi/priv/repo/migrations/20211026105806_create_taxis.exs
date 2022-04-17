defmodule Taxi.Repo.Migrations.CreateTaxis do
  use Ecto.Migration

  def change do
    create table(:taxis) do
      add :location, :string
      add :status, :string

      timestamps()
    end
  end
end
