Feature: Series anchor day
  In order for day 31 not to become day 28 forever after February
  The series keeps the anchor day and each date is calculated from the start, not from the previous occurrence

  @REC-3 @edge
  Scenario Outline: The series calendar respects the anchor day
    Given today is <start>
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    When I create the recurring expense "Test" of R$ 10.00 in account "Nubank", <frequency>, starting <start>, with no end
    Then the first 5 dates of series "Test" are "<dates>"

    Examples:
      | frequency       | start      | dates                                                      |
      | monthly         | 2026-01-31 | 2026-01-31, 2026-02-28, 2026-03-31, 2026-04-30, 2026-05-31 |
      | monthly         | 2028-01-31 | 2028-01-31, 2028-02-29, 2028-03-31, 2028-04-30, 2028-05-31 |
      | monthly         | 2026-01-30 | 2026-01-30, 2026-02-28, 2026-03-30, 2026-04-30, 2026-05-30 |
      | monthly         | 2026-01-29 | 2026-01-29, 2026-02-28, 2026-03-29, 2026-04-29, 2026-05-29 |
      | monthly         | 2028-01-29 | 2028-01-29, 2028-02-29, 2028-03-29, 2028-04-29, 2028-05-29 |
      | monthly         | 2026-02-28 | 2026-02-28, 2026-03-28, 2026-04-28, 2026-05-28, 2026-06-28 |
      | monthly         | 2026-12-31 | 2026-12-31, 2027-01-31, 2027-02-28, 2027-03-31, 2027-04-30 |
      | every 1 months  | 2026-03-31 | 2026-03-31, 2026-04-30, 2026-05-31, 2026-06-30, 2026-07-31 |
      | every 3 months  | 2026-01-31 | 2026-01-31, 2026-04-30, 2026-07-31, 2026-10-31, 2027-01-31 |
      | every 6 months  | 2026-08-31 | 2026-08-31, 2027-02-28, 2027-08-31, 2028-02-29, 2028-08-31 |
      | every 99 months | 2026-03-15 | 2026-03-15, 2034-06-15, 2042-09-15, 2050-12-15, 2059-03-15 |
      | yearly          | 2028-02-29 | 2028-02-29, 2029-02-28, 2030-02-28, 2031-02-28, 2032-02-29 |
      | yearly          | 2027-02-28 | 2027-02-28, 2028-02-28, 2029-02-28, 2030-02-28, 2031-02-28 |
      | weekly          | 2026-03-15 | 2026-03-15, 2026-03-22, 2026-03-29, 2026-04-05, 2026-04-12 |
      | every 2 weeks   | 2026-03-15 | 2026-03-15, 2026-03-29, 2026-04-12, 2026-04-26, 2026-05-10 |
      | every 99 weeks  | 2026-03-15 | 2026-03-15, 2028-02-06, 2029-12-30, 2031-11-23, 2033-10-16 |
      | daily           | 2026-03-15 | 2026-03-15, 2026-03-16, 2026-03-17, 2026-03-18, 2026-03-19 |
      | every 10 days   | 2026-03-15 | 2026-03-15, 2026-03-25, 2026-04-04, 2026-04-14, 2026-04-24 |
      | every 99 days   | 2026-03-15 | 2026-03-15, 2026-06-22, 2026-09-29, 2027-01-06, 2027-04-15 |

  @REC-3 @REC-7
  Scenario: Moving the date of one occurrence with this only does not change the anchor day
    Given today is 2026-01-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the recurring expense "Rent" of R$ 2,000.00 in account "Nubank", monthly, starting 2026-01-31, with no end
    When I edit the 2026-02-28 occurrence of series "Rent" with scope "this only" to date 2026-03-02
    Then the series "Rent" has occurrences on 2026-01-31, 2026-03-02, 2026-03-31, 2026-04-30
    And the 2026-03-02 occurrence of series "Rent" is detached
