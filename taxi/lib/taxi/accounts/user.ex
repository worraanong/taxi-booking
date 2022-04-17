defmodule Taxi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :fullname,  :string
    field :email,     :string
    field :age,       :integer
    field :password,  :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:fullname, :email, :age, :password])
    |> validate_required([:fullname, :email, :age, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:age, 18..100)
    |> unique_constraint(:email)
  end

end
