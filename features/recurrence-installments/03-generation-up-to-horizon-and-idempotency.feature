Feature: Occurrence generation as time passes
  In order for the projection to always have the next 12 months
  Occurrences are generated up to the horizon, without duplicating anything

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the projection horizon is 12 months

  @REC-4 @GER-12 @edge
  Scenario Outline: The last day of the horizon is included
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", monthly, starting <start>, with no end
    Then the series "Test" has <qty> generated occurrences, from <start> to <last>

    Examples:
      | start      | qty | last       |
      | 2026-04-15 | 12  | 2027-03-15 |
      | 2026-03-16 | 12  | 2027-02-16 |

  @GER-12 @REC-3 @REC-4 @edge
  Scenario Outline: A horizon end in a short month becomes the last day of the month
    Given today is 2026-08-31
    And the projection horizon is 6 months
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", <frequency>, starting <start>, with no end
    Then the horizon end is 2027-02-28
    And the series "Test" has <qty> generated occurrences, from <start> to <last>

    Examples:
      | frequency | start      | qty | last       |
      | monthly   | 2026-09-30 | 6   | 2027-02-28 |
      | monthly   | 2026-09-01 | 6   | 2027-02-01 |
      | daily     | 2026-09-01 | 181 | 2027-02-28 |

  @REC-4 @GER-11
  Scenario: The day turning generates the occurrence that entered the horizon
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When the day turns to 2026-04-05
    Then the series "Salary" has 13 generated occurrences, from 2026-04-05 to 2027-04-05

  @REC-4 @edge
  Scenario: A day turn with no new date in the horizon generates nothing
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When the day turns to 2026-03-16
    Then the series "Salary" has 12 generated occurrences, from 2026-04-05 to 2027-03-05

  @REC-4 @STA-3 @edge
  Scenario: An account occurrence on its day stays planned and does not confirm itself
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When the day turns to 2026-04-05
    Then the 2026-04-05 occurrence of series "Salary" is "planned"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @REC-4 @STA-3 @STA-7
  Scenario: On the next day the unconfirmed occurrence becomes overdue
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When the day turns to 2026-04-06
    Then the 2026-04-05 occurrence of series "Salary" is "overdue"
    And I see the warning "1 overdue entry"

  @REC-4 @GER-11
  Scenario: An app closed for weeks generates the missing occurrences as overdue
    Given the projection horizon is 1 month
    And the recurring expense "Electricity" of R$ 180.00 in account "Nubank", monthly, starting 2026-03-20, with no end
    And the series "Electricity" has 1 generated occurrence, from 2026-03-20 to 2026-03-20
    And the app has been closed since 2026-03-15
    When I open the app on 2026-05-25
    Then the series "Electricity" has 4 generated occurrences, from 2026-03-20 to 2026-06-20
    And the 2026-03-20, 2026-04-20 and 2026-05-20 occurrences of series "Electricity" are "overdue"
    And the 2026-06-20 occurrence of series "Electricity" is "planned"
    And no occurrence of series "Electricity" is "confirmed"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @REC-4 @REC-1
  Scenario: Daily series with a 1-month horizon
    Given the projection horizon is 1 month
    When I create the recurring expense "Parking" of R$ 15.00 in account "Nubank", daily, starting 2026-03-16, with no end
    Then the series "Parking" has 31 generated occurrences, from 2026-03-16 to 2026-04-15

  @REC-4 @PRJ-3
  Scenario: Increasing the horizon generates the new occurrences
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When I change the projection horizon to 24 months
    Then the series "Salary" has 24 generated occurrences, from 2026-04-05 to 2028-03-05

  @REC-12 @REC-7 @PRJ-3
  Scenario: Reducing the horizon removes the unedited planned occurrences left outside it
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    And the 2026-12-05 occurrence of series "Salary" was edited with scope "this only" to R$ 5,500.00
    When I change the projection horizon to 6 months
    Then the series "Salary" has occurrences on 2026-04-05, 2026-05-05, 2026-06-05, 2026-07-05, 2026-08-05, 2026-09-05, 2026-12-05
    And the 2026-12-05 occurrence of series "Salary" has amount R$ 5,500.00

  @REC-12 @REC-7 @GER-11 @INV-10
  Scenario: Increasing the horizon again does not duplicate the detached occurrence
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    And the 2026-12-05 occurrence of series "Salary" was edited with scope "this only" to R$ 5,500.00
    And the projection horizon was reduced to 6 months
    When I change the projection horizon to 12 months
    Then the series "Salary" has 12 generated occurrences, from 2026-04-05 to 2027-03-05
    And the series "Salary" has exactly 1 occurrence on 2026-12-05, with amount R$ 5,500.00

  @GER-11 @INV-10
  Scenario: Running generation twice does not duplicate
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When occurrence generation runs again
    And occurrence generation runs again
    Then the series "Salary" has 12 generated occurrences, from 2026-04-05 to 2027-03-05
    And each occurrence of series "Salary" has a unique identity "series + sequence number", from 1 to 12

  @GER-11 @INV-10 @integration
  Scenario: Generation on two devices does not duplicate
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    When the day turns to 2026-04-05 on device "iPhone" and on device "Mac" while offline
    And both devices sync
    Then the series "Salary" has 13 generated occurrences, from 2026-04-05 to 2027-04-05
    And the series "Salary" has exactly 1 occurrence on 2027-04-05

  @GER-11 @REC-7 @INV-10
  Scenario: An occurrence with a moved date is not recreated on the anchor date
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    And the 2026-04-05 occurrence of series "Salary" was edited with scope "this only" to date 2026-04-07
    When occurrence generation runs again
    Then the series "Salary" has no occurrence on 2026-04-05
    And the series "Salary" has 12 generated occurrences, from 2026-04-07 to 2027-03-05
    And the 2026-04-07 occurrence of series "Salary" has identity "series + no. 1"

  @REC-7 @GER-11 @INV-10
  Scenario: A deleted occurrence does not come back when generation runs again
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-04-05, with no end
    And the 2026-06-05 occurrence of series "Salary" was deleted with scope "this only"
    When I change the projection horizon to 24 months
    And occurrence generation runs again
    Then the series "Salary" has no occurrence on 2026-06-05
    And the series "Salary" has 23 generated occurrences, from 2026-04-05 to 2028-03-05
