# Check: (3,000 + 4,500 + 3,900) ÷ 3 = 3,800.00; (4,500 + 3,900) ÷ 2 = 4,200.00; 3,000.01 ÷ 3 = 1,000.0033 → 1,000.00; 3,000.02 ÷ 3 = 1,000.0067 → 1,000.01; 2,000.01 ÷ 2 = 1,000.005 → 1,000.01; 6,900 ÷ 3 = 2,300.00; turn of the month (4,500 + 3,900 + 3,600) ÷ 3 = 4,000.00.
Feature: Cost of living

  Background:
    Given today is 2026-03-15
    And the realized Total outflows for 2026-03 up to today is R$ 9,999.00

  @IND-8
  Scenario: With no closed month, the cost of living has no data
    Given the realized Total outflows were:
      | month | Total outflows |
    Then the cost of living is "no data"

  @IND-8
  Scenario: With 1 closed month, the cost of living is its Total outflows
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 3,900.00

  @IND-8
  Scenario: With 2 closed months, the cost of living is the average of the 2
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 4,200.00

  @IND-8
  Scenario: With 3 closed months, the cost of living is the average of the 3, without the current month
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 3,800.00

  @IND-8 @edge
  Scenario: With more than 3 closed months, only the last 3 count
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-11 | R$ 10,000.00   |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 3,800.00

  @IND-8 @GER-10 @edge
  Scenario: A 3-month average rounds down to the cent
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 1,000.00    |
      | 2026-01 | R$ 1,000.00    |
      | 2026-02 | R$ 1,000.01    |
    Then the cost of living is R$ 1,000.00

  @IND-8 @GER-10 @edge
  Scenario: A 3-month average rounds up to the cent
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 1,000.01    |
      | 2026-01 | R$ 1,000.01    |
      | 2026-02 | R$ 1,000.00    |
    Then the cost of living is R$ 1,000.01

  @IND-8 @GER-10 @edge
  Scenario: An average with half a cent rounds away from zero
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2026-01 | R$ 1,000.00    |
      | 2026-02 | R$ 1,000.01    |
    Then the cost of living is R$ 1,000.01

  @IND-8 @edge
  Scenario: A closed month with no spending counts as zero
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 0.00        |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 2,300.00

  @IND-8 @edge
  Scenario: A partial first month counts as a whole month
    Given the first entry that counts in an indicator is the expense "Groceries" of R$ 400.00 in account "Nubank" on 2026-02-20, confirmed
    And the realized Total outflows were:
      | month   | Total outflows |
      | 2026-02 | R$ 1,200.00    |
    Then the cost of living is R$ 1,200.00

  @IND-8 @IND-6 @edge
  Scenario: A transfer to saving also marks the start of use
    Given the first entry that counts in an indicator is the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2025-12-10, confirmed
    And the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 0.00        |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    Then the cost of living is R$ 2,800.00

  @IND-8 @IND-11
  Scenario: The cost of living uses only the realized values of closed months
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    And the expense "Vehicle Tax" of R$ 1,200.00 in account "Nubank" on 2026-02-20, planned
    Then the cost of living is R$ 4,200.00

  @IND-8 @GER-3
  Scenario: At the turn of the month the month that ended starts to count
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    And the realized Total outflows for 2026-03 closes at R$ 3,600.00
    When the day turns to 2026-04-01
    Then the cost of living is R$ 4,000.00

  @IND-10 @IND-8
  Scenario: The cost of living opens one item per month
    Given the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 4,500.00    |
      | 2026-02 | R$ 3,900.00    |
    When I open the cost of living
    Then I see the items "2025-12 R$ 3,000.00, 2026-01 R$ 4,500.00, 2026-02 R$ 3,900.00"
    And each item opens the realized Total outflows list for that month
