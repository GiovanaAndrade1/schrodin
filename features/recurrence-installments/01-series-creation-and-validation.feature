Feature: Recurring series creation
  In order to add salary, rent and subscriptions only once
  As a user
  I want to create series with a frequency and an end

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months

  @REC-1 @REC-2 @REC-4 @REC-10
  Scenario: Monthly income with no end generates planned entries up to the horizon
    When I create the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    Then the series "Salary" has 12 generated occurrences, from 2026-04-05 to 2027-03-05
    And all occurrences of series "Salary" are "planned"
    And the 2026-04-05 occurrence of series "Salary" shows no position

  @REC-1 @edge
  Scenario Outline: "Every N" accepts N from 1 to 99
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", every <N> <unit>, starting 2026-03-16, with no end
    Then the series "Test" is created
    And the second date of series "Test" is <second date>

    Examples:
      | N  | unit   | second date |
      | 1  | days   | 2026-03-17  |
      | 99 | days   | 2026-06-23  |
      | 1  | weeks  | 2026-03-23  |
      | 99 | weeks  | 2028-02-07  |
      | 1  | months | 2026-04-16  |
      | 99 | months | 2034-06-16  |

  @REC-1 @error @edge
  Scenario Outline: "Every N" outside 1 to 99 is rejected
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", every <N> months, starting 2026-03-16, with no end
    Then the operation is blocked with the message "The interval must be a whole number from 1 to 99"
    And no series is created

    Examples:
      | N   |
      | 0   |
      | 100 |
      | -1  |
      | 2.5 |

  @REC-2 @REC-10 @edge
  Scenario: Ending after 1 occurrence generates exactly one
    When I create the recurring expense "Enrollment" of R$ 300.00 in account "Nubank", monthly, starting 2026-04-10, for 1 occurrence
    Then the series "Enrollment" has 1 generated occurrence, from 2026-04-10 to 2026-04-10
    And the 2026-04-10 occurrence of series "Enrollment" shows position "1/1"

  @REC-2 @REC-4 @REC-10 @edge
  Scenario: Ending after 999 daily occurrences generates only up to the horizon
    When I create the recurring expense "Medicine" of R$ 2.00 in account "Nubank", daily, starting 2026-03-16, for 999 occurrences
    Then the series "Medicine" has 365 generated occurrences, from 2026-03-16 to 2027-03-15
    And the 2027-03-15 occurrence of series "Medicine" shows position "365/999"
    And the last date of series "Medicine" is 2028-12-08

  @REC-2 @error @edge
  Scenario Outline: An occurrence-count end outside 1 to 999 is rejected
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", monthly, starting 2026-04-01, for <N> occurrences
    Then the operation is blocked with the message "The number of occurrences must be 1 to 999"

    Examples:
      | N    |
      | 0    |
      | 1000 |
      | -5   |

  @REC-2 @REC-3 @edge
  Scenario Outline: An end date is inclusive
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", <frequency>, starting <start>, until <end>
    Then the series "Test" has <qty> generated occurrences, from <start> to <last>

    Examples:
      | frequency | start      | end        | qty | last       |
      | monthly   | 2026-03-31 | 2026-06-30 | 4   | 2026-06-30 |
      | monthly   | 2026-03-31 | 2026-06-29 | 3   | 2026-05-31 |
      | weekly    | 2026-03-16 | 2026-04-13 | 5   | 2026-04-13 |
      | weekly    | 2026-03-16 | 2026-04-12 | 4   | 2026-04-06 |
      | daily     | 2026-03-16 | 2026-03-16 | 1   | 2026-03-16 |

  @REC-2 @error
  Scenario: An end date before the start is rejected
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", monthly, starting 2026-04-10, until 2026-04-09
    Then the operation is blocked with the message "The end date can't be before the start of the series"

  @REC-1 @CON-3 @error
  Scenario: A series can't start before the account's opening balance
    Given the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    When I create the recurring expense "Market" of R$ 80.00 in account "Wallet", weekly, starting 2026-02-22, with no end
    Then the operation is blocked with the message "The date can't be before the opening balance of account Wallet (2026-03-01)"

  @REC-1 @LAN-7 @GER-12 @error @edge
  Scenario: A series can't start after the horizon
    When I create the recurring expense "Vehicle Tax" of R$ 900.00 in account "Nubank", yearly, starting 2027-03-16, with no end
    Then the operation is blocked with the message "The date can't be after 2027-03-15"

  @REC-1 @LAN-3 @error
  Scenario: Recurring income on a card is not allowed
    When I create the recurring income "Cashback" of R$ 10.00 on card "Purple", monthly, starting 2026-04-01, with no end
    Then the operation is blocked with the message "Recurring income can only be added to an account"

  @REC-1 @AJU-1 @error
  Scenario: An adjustment can't be recurring
    When I try to make the balance adjustment of account "Nubank" recurring
    Then the operation is blocked with the message "A balance adjustment can't be recurring"

  @REC-12 @STA-2
  Scenario: A series created with a start in the past creates the past occurrences as confirmed
    When I create the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-01-05, with no end
    Then I see the warning "3 past occurrences will be created as confirmed"
    And the 2026-01-05, 2026-02-05 and 2026-03-05 occurrences of series "Salary" are "confirmed"
    And the 2026-04-05 occurrence of series "Salary" is "planned"
    And the actual balance of account "Nubank" is R$ 16,000.00

  @REC-12 @STA-3
  Scenario: A series with a start in the past can have the past occurrences created as planned
    When I create the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-01-05, with no end
    And I choose to create the past occurrences as planned
    Then the 2026-01-05, 2026-02-05 and 2026-03-05 occurrences of series "Salary" are "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And I see the warning "3 overdue entries"

  @REC-12 @STA-2 @edge
  Scenario: A series that starts today creates the first occurrence as confirmed
    When I create the recurring expense "Gym" of R$ 120.00 in account "Nubank", monthly, starting 2026-03-15, with no end
    Then the 2026-03-15 occurrence of series "Gym" is "confirmed"
    And the 2026-04-15 occurrence of series "Gym" is "planned"
    And the actual balance of account "Nubank" is R$ 880.00
