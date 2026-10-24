Feature: Occurrence position display
  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the projection horizon is 12 months

  @REC-10
  Scenario: A count-based series shows k/N
    Given the recurring expense "Course" of R$ 400.00 in account "Nubank", monthly, starting 2026-04-10, for 12 occurrences
    Then the 2026-06-10 occurrence of series "Course" shows position "3/12"
    And the displayed title of the occurrence is "Course (3/12)"

  @REC-10 @REC-4
  Scenario: A series with an end date calculates N from the full calendar
    Given the recurring income "Stipend" of R$ 1,500.00 in account "Nubank", monthly, starting 2026-04-05, until 2027-12-05
    Then the series "Stipend" has 12 generated occurrences, from 2026-04-05 to 2027-03-05
    And the 2026-04-05 occurrence of series "Stipend" shows position "1/21"
    And the 2027-03-05 occurrence of series "Stipend" shows position "12/21"
