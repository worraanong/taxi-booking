defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Taxi.{Repo, Accounts.User}
  alias Taxi.Sales.{Taxi, Allocation}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Repo)
    Hound.end_session
  end

  given_ ~r/^the following taxis are on duty$/, fn state, %{table_data: table} ->
    table
    |> Enum.map(fn taxi -> Taxi.changeset(%Taxi{}, taxi) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end
  given_ ~r/^the following users are registered$/, fn state, %{table_data: table} ->
    table
    |> Enum.map(fn user -> User.changeset(%User{}, user) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end
  given_ ~r/^the current allocations$/, fn state, %{table_data: table} ->
    table
    |> Enum.map(fn allocation -> Allocation.changeset(%Allocation{}, allocation) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end

  and_ ~r/^I want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)" which is "(?<distance>[^"]+)" kilometers apart$/,
  fn state, %{pickup_address: pickup_address, dropoff_address: dropoff_address, distance: distance} ->
    {:ok, state |> Map.put(:pickup_address, pickup_address)
                |> Map.put(:dropoff_address, dropoff_address)
                |> Map.put(:distance, distance)
    }
  end
  and_ ~r/^I registered with email "(?<email>[^"]+)" and password "(?<password>[^"]+)"$/,
  fn state, %{email: email, password: password} ->
    {:ok, state |> Map.put(:email, email)
                |> Map.put(:password, password)
    }
  end
  and_ ~r/^I log in$/, fn state ->
    navigate_to "/sessions/new"
    fill_field({:id, "email"}, state[:email])
    fill_field({:id, "password"}, state[:password])
    click({:id, "login_submit"})
    {:ok, state}
  end
  and_ ~r/^I open the booking page$/, fn state ->
    navigate_to "/bookings/new"
    {:ok, state}
  end
  and_ ~r/^I enter the booking information$/, fn state ->
    fill_field({:id, "pickup_address"}, state[:pickup_address])
    fill_field({:id, "dropoff_address"}, state[:dropoff_address])
    fill_field({:id, "distance"}, state[:distance])
    {:ok, state}
  end

  when_ ~r/^I submit the booking request$/, fn state ->
    click({:id, "submit_button"})
    {:ok, state}
  end

  then_ ~r/^I should receive a confirmation message$/, fn state ->
    assert visible_in_page? ~r/Your taxi will arrive in \d+ minutes/
    {:ok, state}
  end
  then_ ~r/^I should receive a rejection message$/, fn state ->
    assert visible_in_page? ~r/At present, there is no taxi available!/
    {:ok, state}
  end
  then_ ~r/^I should receive a 'Please log in' message$/, fn state ->
    assert visible_in_page? ~r/Please log in before proceed to book your Taxi/
    {:ok, state}
  end
  then_ ~r/^I should see booking info$/, fn state ->
    assert visible_in_page? ~r/Driver/
    # number of seats
    assert visible_in_page? ~r/3 seat/
    # price
    assert visible_in_page? ~r/1.05 £/
    # taxi location
    assert visible_in_page? ~r/Raatuse 22/
    # driver's full name
    # assert visible_in_page? ~r/Giacomo Liaden/
    {:ok, state}
  end

end
