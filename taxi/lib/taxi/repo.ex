defmodule Taxi.Repo do
  use Ecto.Repo,
    otp_app: :taxi,
    adapter: Ecto.Adapters.Postgres
end
