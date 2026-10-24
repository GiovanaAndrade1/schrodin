Feature: Lowest future balance and first negative day
  As a user
  I want to see the lowest point of the projection
  In order to answer "am I safe?"

  Background:
    Given today is 2026-03-15
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 1 month

  @PRJ-7 @edge
  Scenario: Tie for the lowest balance in two dips: the earliest date wins
    Given the account "Nubank" of kind "checking" with opening balance R$ 300.00 on 2026-03-01
    And the expense "Repair" of R$ 500.00 in account "Nubank" on 2026-03-20, planned
    And the income "Freelance" of R$ 1,000.00 in account "Nubank" on 2026-03-25, planned
    And the expense "Insurance" of R$ 1,000.00 in account "Nubank" on 2026-04-05, planned
    And the income "Reimbursement" of R$ 200.00 in account "Nubank" on 2026-04-06, planned
    Then the consolidated projected balance on 2026-03-20 is -R$ 200.00
    And the consolidated projected balance on 2026-04-05 is -R$ 200.00
    And the consolidated projected balance on 2026-04-06 is R$ 0.00
    And the lowest future balance is -R$ 200.00 on 2026-03-20
    And the first negative day is 2026-03-20

  @PRJ-7 @edge
  Scenario: A balance of exactly zero is not a negative day
    Given the account "Nubank" of kind "checking" with opening balance R$ 500.00 on 2026-03-01
    And the expense "Course" of R$ 500.00 in account "Nubank" on 2026-03-20, planned
    Then the lowest future balance is R$ 0.00 on 2026-03-20
    And there is no negative day

  @PRJ-7 @edge
  Scenario: Today can be the lowest balance
    Given the account "Nubank" of kind "checking" with opening balance R$ 100.00 on 2026-03-01
    And the income "Salary" of R$ 2,000.00 in account "Nubank" on 2026-03-16, planned
    Then the lowest future balance is R$ 100.00 on 2026-03-15
    And there is no negative day

  @PRJ-7 @CON-2 @edge
  Scenario: A negative balance today makes today the first negative day
    Given the account "Nubank" of kind "checking" with opening balance -R$ 100.00 on 2026-03-01
    And the income "Salary" of R$ 2,000.00 in account "Nubank" on 2026-03-20, planned
    Then the first negative day is 2026-03-15
    And the lowest future balance is -R$ 100.00 on 2026-03-15

  @PRJ-7 @PRJ-5
  Scenario: Home highlights use the consolidated balance; the account screen uses the account
    Given the account "Nubank" of kind "checking" with opening balance R$ 100.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 500.00 on 2026-03-01
    And the expense "Groceries" of R$ 300.00 in account "Nubank" on 2026-03-20, planned
    Then the projected balance of account "Nubank" on 2026-03-20 is -R$ 200.00
    And the consolidated projected balance on 2026-03-20 is R$ 300.00
    And the lowest future balance is R$ 300.00 on 2026-03-20
    And there is no negative day
    And on the account "Nubank" screen the lowest balance is -R$ 200.00 on 2026-03-20
    And on the account "Nubank" screen the first negative day is 2026-03-20
