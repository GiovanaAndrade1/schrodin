Feature: Projection horizon
  As a user
  I want to choose how far the projection goes
  In order to balance long-term view and accuracy

  @PRJ-3 @GER-12 @edge
  Scenario Outline: Last projected day according to the horizon
    Given today is <today>
    When I change the projection horizon to <months> months
    Then the projection runs from <today> to <last day>

    Examples:
      | today      | months | last day   |
      | 2026-03-15 | 1      | 2026-04-15 |
      | 2026-03-15 | 12     | 2027-03-15 |
      | 2026-03-15 | 24     | 2028-03-15 |
      | 2026-03-31 | 1      | 2026-04-30 |
      | 2026-01-31 | 1      | 2026-02-28 |
      | 2027-02-28 | 12     | 2028-02-28 |
      | 2028-02-29 | 12     | 2029-02-28 |
      | 2027-12-31 | 2      | 2028-02-29 |

  @PRJ-3
  Scenario: The default horizon is 12 months
    Given today is 2026-03-15
    And it is the first use of the app
    Then the projection horizon is 12 months
    And the projection runs from 2026-03-15 to 2027-03-15

  @PRJ-3 @error @edge
  Scenario Outline: A horizon outside 1 to 24 months is rejected
    Given today is 2026-03-15
    And the projection horizon is 12 months
    When I change the projection horizon to <amount> months
    Then the operation is blocked with the message "The horizon must be 1 to 24 months"
    And the projection horizon is 12 months

    Examples:
      | amount |
      | 0      |
      | 25     |
      | -1     |
      | 1.5    |

  @PRJ-3 @PRJ-7 @LAN-7
  Scenario: Reducing the horizon hides, but does not delete, a manual entry beyond the new end
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months
    And the expense "Vehicle Tax" of R$ 3,000.00 in account "Nubank" on 2026-12-05, planned
    When I change the projection horizon to 6 months
    Then the expense "Vehicle Tax" is "planned"
    And the projection runs from 2026-03-15 to 2026-09-15
    And there is no negative day

  @PRJ-3 @REC-12 @REC-4 @GER-11 @INV-10
  Scenario: Reducing the horizon removes unedited planned occurrences beyond the new end; increasing it regenerates them
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months
    And the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    And I edit the 2026-11-05 occurrence of series "Salary" with scope "this only" to R$ 5,500.00
    When I change the projection horizon to 6 months
    Then the series "Salary" has occurrences on 2026-04-05, 2026-05-05, 2026-06-05, 2026-07-05, 2026-08-05, 2026-09-05 and 2026-11-05
    And the projected balance of account "Nubank" on 2026-09-15 is R$ 31,000.00
    When I change the projection horizon to 12 months
    Then the series "Salary" has 12 occurrences between 2026-04-05 and 2027-03-05, without duplicating the one on 2026-11-05
    And the 2026-11-05 occurrence of series "Salary" is worth R$ 5,500.00

  @PRJ-3 @PRJ-7 @edge
  Scenario: A statement due after the horizon does not count in the highlights
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 1 month
    And the purchase "Laptop" of R$ 5,000.00 on card "Black" on 2026-03-30
    Then the purchase "Laptop" is in the 2026-05 statement of card "Black"
    And the lowest future balance is R$ 1,000.00 on 2026-03-15
    And there is no negative day
    When I change the projection horizon to 2 months
    Then the lowest future balance is -R$ 4,000.00 on 2026-05-05
    And the first negative day is 2026-05-05
