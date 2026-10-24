Feature: Daily average

  @IND-9 @GER-10 @edge
  Scenario Outline: Daily spending ÷ days elapsed (current month) or ÷ days in the month (past month)
    Given today is <today>
    And the first account was created on 2025-12-01
    And the realized Daily spending for <month> is <daily spending>
    Then the realized Daily average for <month> is <average>

    Examples:
      | today      | month   | daily spending | average  | calculation                  |
      | 2026-03-15 | 2026-03 | R$ 600.00      | R$ 40.00 | ÷ 15 (current, up to today)  |
      | 2026-03-01 | 2026-03 | R$ 35.00       | R$ 35.00 | ÷ 1 (first day)              |
      | 2026-03-02 | 2026-03 | R$ 10.25       | R$ 5.13  | ÷ 2 = 5.125 → away from zero |
      | 2026-03-31 | 2026-03 | R$ 620.00      | R$ 20.00 | ÷ 31 (last day)              |
      | 2026-03-15 | 2026-02 | R$ 1,000.00    | R$ 35.71 | ÷ 28 (Feb, not a leap year)  |
      | 2028-03-10 | 2028-02 | R$ 1,000.00    | R$ 34.48 | ÷ 29 (Feb, leap year)        |
      | 2026-03-15 | 2026-01 | R$ 1,000.00    | R$ 32.26 | ÷ 31                         |
      | 2026-05-15 | 2026-04 | R$ 1,000.00    | R$ 33.33 | ÷ 30                         |
      | 2026-03-15 | 2026-02 | R$ 0.00        | R$ 0.00  | no daily spending            |
      | 2026-03-15 | 2026-03 | -R$ 15.00      | -R$ 1.00 | negative due to refund       |

  @IND-9 @GER-3
  Scenario: The current month's divisor changes at the turn of the day
    Given today is 2026-03-15
    And the first account was created on 2025-12-01
    And the realized Daily spending for 2026-03 is R$ 600.00
    When the day turns to 2026-03-16
    Then the realized Daily average for 2026-03 is R$ 37.50

  @IND-9 @edge
  Scenario Outline: Use started in the month: current divides since the start; past divides by the whole month
    Given the first account was created on <start>
    And today is <today>
    And the realized Daily spending for <month> is <daily spending>
    Then the realized Daily average for <month> is <average>

    Examples:
      | start      | today      | month   | daily spending | average  | calculation               |
      | 2026-03-10 | 2026-03-15 | 2026-03 | R$ 120.00      | R$ 20.00 | ÷ 6 (10 to 15, inclusive) |
      | 2026-03-15 | 2026-03-15 | 2026-03 | R$ 42.00       | R$ 42.00 | ÷ 1 (started today)       |
      | 2026-02-20 | 2026-03-15 | 2026-02 | R$ 280.00      | R$ 10.00 | ÷ 28 (last month, full)   |

  @IND-9 @IND-11
  Scenario: The forecast Daily average divides the forecast Daily spending by the days in the month
    Given today is 2026-02-10
    And the first account was created on 2025-12-01
    And the realized Daily spending for 2026-02 is R$ 300.00 and the forecast Daily spending is R$ 560.00
    Then the realized Daily average for 2026-02 is R$ 30.00
    And the forecast Daily average for 2026-02 is R$ 20.00

  @IND-9 @edge
  Scenario: A future month shows only the forecast daily average
    Given today is 2026-03-15
    And the forecast Daily spending for 2026-04 is R$ 300.00
    Then the realized Daily average for 2026-04 is not shown
    And the forecast Daily average for 2026-04 is R$ 10.00
