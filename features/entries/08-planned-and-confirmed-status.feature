Feature: Planned, confirmed and overdue status

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months

  @STA-1 @STA-2 @edge
  Scenario Outline: Default status by date
    When I add the expense "Test" of R$ 50.00 to account "Nubank" on <date>
    Then the expense "Test" is "<status>"
    And the actual balance of account "Nubank" is <balance>

    Examples:
      | date       | status    | balance     |
      | 2026-03-14 | confirmed | R$ 950.00   |
      | 2026-03-15 | confirmed | R$ 950.00   |
      | 2026-03-16 | planned   | R$ 1,000.00 |

  @STA-2 @STA-3
  Scenario: Adding with a past date as planned is created already overdue
    When I add the expense "Electricity" of R$ 180.00 to account "Nubank" on 2026-03-10 as planned
    Then the expense "Electricity" is "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @STA-2 @STA-3 @edge
  Scenario: A planned entry dated today is not overdue
    When I add the expense "Electricity" of R$ 180.00 to account "Nubank" on 2026-03-15 as planned
    Then the expense "Electricity" is "planned"

  @STA-2 @STA-8 @error
  Scenario: Confirmed with a future date is blocked on creation
    When I add the expense "Electricity" of R$ 180.00 to account "Nubank" on 2026-03-16 as confirmed
    Then the operation is blocked with the message "A confirmed entry can't have a future date"

  @STA-3 @GER-3
  Scenario: A planned entry becomes overdue only when the date is in the past
    Given the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-16, planned
    Then the expense "Rent" is "planned"
    When the day turns to 2026-03-16
    Then the expense "Rent" is "planned"
    When the day turns to 2026-03-17
    Then the expense "Rent" is "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @STA-4 @PRJ-2
  Scenario: An overdue entry counts in the projection as if it were today, only once
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 820.00
    And the projected balance of account "Nubank" on 2026-03-16 is R$ 820.00

  @STA-5 @CON-4
  Scenario: Confirming with the actual amount and date
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I confirm the expense "Electricity" with amount R$ 203.40 on 2026-03-14
    Then the expense "Electricity" is "confirmed"
    And the expense "Electricity" has date 2026-03-14 and amount R$ 203.40
    And the actual balance of account "Nubank" is R$ 796.60

  @STA-5 @LAN-4
  Scenario: Confirming accepts an expression in the amount
    Given the expense "Groceries" of R$ 300.00 in account "Nubank" on 2026-03-14, planned
    When I confirm the expense "Groceries" typing "120+35,90" in the amount on 2026-03-14
    Then the actual balance of account "Nubank" is R$ 844.10

  @STA-5 @STA-8 @error
  Scenario: Confirming with a future date is blocked
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I confirm the expense "Electricity" with amount R$ 180.00 on 2026-03-16
    Then the operation is blocked with the message "A confirmed entry can't have a future date"
    And the expense "Electricity" is "overdue"

  @STA-5 @CON-3 @error
  Scenario: Confirming with a date before the opening date is blocked
    Given the expense "Market" of R$ 60.00 in account "Wallet" on 2026-03-05, planned
    When I confirm the expense "Market" with amount R$ 60.00 on 2026-02-27
    Then the operation is blocked with the message "The date can't be before the opening balance of account Wallet (2026-03-01)"

  @STA-5 @LAN-1 @error
  Scenario: Confirming with a zero amount is blocked
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I confirm the expense "Electricity" with amount R$ 0.00 on 2026-03-14
    Then the operation is blocked with the message "The amount must be greater than zero"

  @STA-5 @STA-8 @edge
  Scenario: Confirming a future planned entry suggests today's date
    Given the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-20, planned
    When I open the confirmation of the expense "Rent"
    Then the suggested date is 2026-03-15
    When I confirm without changing amount or date
    Then the expense "Rent" has date 2026-03-15 and amount R$ 1,500.00
    And the expense "Rent" is "confirmed"
    And the actual balance of account "Nubank" is -R$ 500.00

  @STA-8 @INV-6
  Scenario: A confirmed entry edited to a future date goes back to planned with a warning
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed
    When I edit the expense "Groceries" to date 2026-03-20
    Then the expense "Groceries" is "planned"
    And I see the warning "The entry went back to planned because the date is in the future"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @STA-9 @STA-3
  Scenario: Unconfirming with a past date becomes overdue
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-10, confirmed
    When I unconfirm the expense "Groceries"
    Then the expense "Groceries" is "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @STA-9 @edge
  Scenario: Unconfirming with today's date becomes planned, not overdue
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed
    When I unconfirm the expense "Groceries"
    Then the expense "Groceries" is "planned"

  @STA-9 @CON-4
  Scenario: An unconfirmed income leaves the actual balance
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the actual balance of account "Nubank" is R$ 6,000.00
    When I unconfirm the income "Salary"
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the income "Salary" is "overdue"
