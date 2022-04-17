defmodule Taxi.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :fullname,  :string
      add :email,     :string
      add :age,       :integer
      add :password,  :string

      timestamps()
    end
  end
end
