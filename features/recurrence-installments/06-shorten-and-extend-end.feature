Feature: Series end change
  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the projection horizon is 12 months
    And the recurring expense "Gym" of R$ 120.00 in account "Nubank", monthly, starting 2026-04-01, for 6 occurrences

  @REC-11 @REC-10
  Scenario: Shortening the number of occurrences deletes the planned ones left outside
    When I change the end of series "Gym" to 3 occurrences
    Then the series "Gym" has 3 generated occurrences, from 2026-04-01 to 2026-06-01
    And the 2026-07-01, 2026-08-01 and 2026-09-01 occurrences no longer exist
    And the 2026-06-01 occurrence of series "Gym" shows position "3/3"

  @REC-11 @REC-2
  Scenario: Shortening to a date deletes the planned occurrences after it
    When I change the end of series "Gym" to until 2026-05-15
    Then the series "Gym" has 2 generated occurrences, from 2026-04-01 to 2026-05-01

  @REC-11 @REC-10
  Scenario: Extending generates the new occurrences
    When I change the end of series "Gym" to 8 occurrences
    Then the series "Gym" has 8 generated occurrences, from 2026-04-01 to 2026-11-01
    And the 2026-09-01 occurrence of series "Gym" shows position "6/8"

  @REC-11 @REC-4 @edge
  Scenario: Extending beyond the horizon only generates up to the horizon
    When I change the end of series "Gym" to 14 occurrences
    Then the series "Gym" has 12 generated occurrences, from 2026-04-01 to 2027-03-01
    When the day turns to 2026-04-01
    Then the series "Gym" has 13 generated occurrences, from 2026-04-01 to 2027-04-01

  @REC-11 @REC-2
  Scenario: Changing an occurrence-count end to never generates up to the horizon
    When I change the end of series "Gym" to never
    Then the series "Gym" has 12 generated occurrences, from 2026-04-01 to 2027-03-01
    And the 2026-04-01 occurrence of series "Gym" shows no position

  @REC-11 @REC-7 @INV-10
  Scenario: Extending does not recreate a deleted occurrence
    Given the 2026-05-01 occurrence of series "Gym" was deleted with scope "this only"
    When I change the end of series "Gym" to 8 occurrences
    Then the series "Gym" has no occurrence on 2026-05-01
    And the series "Gym" has 7 occurrences, from 2026-04-01 to 2026-11-01

  @REC-11 @REC-6 @REC-10 @edge
  Scenario: Shortening below the confirmed occurrences keeps the confirmed ones
    Given today is 2026-07-15
    And the 2026-04-01, 2026-05-01, 2026-06-01 and 2026-07-01 occurrences of series "Gym" are "confirmed"
    When I change the end of series "Gym" to 2 occurrences
    Then the 2026-05-01, 2026-06-01 and 2026-07-01 occurrences of series "Gym" are still "confirmed"
    And the 2026-05-01, 2026-06-01 and 2026-07-01 occurrences show no position
    And the 2026-08-01 and 2026-09-01 occurrences no longer exist
    And the actual balance of account "Nubank" is R$ 520.00

  @REC-11 @REC-2 @error
  Scenario: A new end before the start is rejected
    When I change the end of series "Gym" to until 2026-03-31
    Then the operation is blocked with the message "The end date can't be before the start of the series"
    And the series "Gym" has 6 generated occurrences, from 2026-04-01 to 2026-09-01
