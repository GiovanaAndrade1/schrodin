Feature: Overdue entry warnings

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    And the income "Freelance" of R$ 700.00 in account "Nubank" on 2026-03-12, planned

  @STA-7
  Scenario: The badge counts the overdue entries
    Then the overdue badge shows 2

  @STA-7 @STA-3
  Scenario Outline: An overdue entry leaves the badge when resolved
    When I <action> the expense "Electricity"
    Then the overdue badge shows 1

    Examples:
      | action                   |
      | confirm                  |
      | reschedule to 2026-03-20 |
      | reschedule to 2026-03-15 |
      | delete and confirm       |

  @STA-7 @edge
  Scenario: Rescheduling to another past date stays overdue
    When I reschedule the expense "Electricity" to 2026-03-14
    Then the overdue badge shows 2

  @STA-7 @TRF-5 @edge
  Scenario: An overdue transfer counts only once in the badge
    Given the transfer "Change" of R$ 50.00 from account "Nubank" to account "Wallet" on 2026-03-11, planned
    Then the overdue badge shows 3

  @STA-7 @GER-3
  Scenario: Only one notification, on the day the entry becomes overdue
    Given overdue notifications are on
    And the expense "Internet" of R$ 120.00 in account "Nubank" on 2026-03-15, planned
    When the day turns to 2026-03-16
    Then I receive the notification "Internet is overdue"
    When the day turns to 2026-03-17
    Then I receive no new notification about "Internet"

  @STA-7
  Scenario: With notifications off, only the badge warns
    Given overdue notifications are off
    And the expense "Internet" of R$ 120.00 in account "Nubank" on 2026-03-15, planned
    When the day turns to 2026-03-16
    Then I receive no notification
    And the overdue badge shows 3
