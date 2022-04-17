Feature: Create booking
  As a customer
  Such that I go to destination
  I want to arrange a taxi ride

  Scenario: Booking accepted
    Given the following taxis are on duty
          | id | location     | status    | total_seat | cost_per_kilo | user_id |
          | 1  | Narva 25     | BUSY      | 1          | 0.5           | 111     |
          | 2  | Narva 27     | AVAILABLE | 2          | 1.5           | 122     |
          | 3  | Raatuse 22   | AVAILABLE | 3          | 0.5           | 3       |
    Given the following users are registered
          | id | email	       | password         | age | fullname       |
          | 1  | Jon@Snow.ee   | You know nothing | 60  | Jon Snow       |
          | 2  | JohnDoe@ut.ee | 12345            | 20  | John Doe       |
          | 3  | takso@ut.ee   | tasko            | 25  | Giacomo Liaden |
    Given the current allocations
          | status     | booking_id | taxi_id |
          | COMPLETED  | 42         | 2       |
    # foriegn keys; user_id, booking_id, taxi_id, actually unused

    And I want to go from "Narva 27" to "Tasku Centre" which is "2.1" kilometers apart
    And I registered with email "Jon@Snow.ee" and password "You know nothing"
    And I log in
    And I open the booking page
    And I enter the booking information
    When I submit the booking request
    Then I should receive a confirmation message
    Then I should see booking info

  Scenario: Booking rejected
    Given the following taxis are on duty
          | location	 | status    |
          | Narva 25     | BUSY      |
          | Narva 27     | BUSY      |
    Given the following users are registered
          | email	        | password         | age | fullname |
          | Jon@Snow.ee   | You know nothing | 60  | Jon Snow |
          | JohnDoe@ut.ee | 12345            | 20  | John Doe |
    And I want to go from "Narva 27" to "Tasku Centre" which is "2.1" kilometers apart
    And I registered with email "JohnDoe@ut.ee" and password "12345"
    And I log in
    And I open the booking page
    And I enter the booking information
    When I submit the booking request
    Then I should receive a rejection message

  Scenario: Need to Log in before make a booking
    Given the following taxis are on duty
          | location	 | status    |
          | Narva 27     | AVAILABLE |
    And I want to go from "Narva 27" to "Tasku Centre" which is "2.1" kilometers apart
    When I open the booking page
    Then I should receive a 'Please log in' message