# Checks: realized — Outflows 2,200 (overdue Electricity and planned Gift left out); Daily spending 300 + 140 = 440; % 1,000 ÷ 6,000 = 16.67% → 16.7%; average 440 ÷ 15 = 29.333 → 29.33. Forecast — Outflows 2,200 + 190 + 120 + 250 = 2,760; Daily spending 440 + 60 = 500; Performance 6,800 − 3,260 = 3,540; % 1,500 ÷ 6,800 = 22.06% → 22.1%; average 500 ÷ 31 = 16.129 → 16.13. Confirming Electricity: realized 2,200 + 203.40 = 2,403.40; forecast 2,760 − 190 + 203.40 = 2,773.40.
Feature: Realized and forecast indicators

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the first account was created on 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the income "Salary" of R$ 6,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the income "Freelance" of R$ 800.00 in account "Nubank" on 2026-03-25, planned
    And the expense "Rent" of R$ 2,200.00 in account "Nubank" on 2026-03-10, confirmed
    And the expense "Electricity" of R$ 190.00 in account "Nubank" on 2026-03-12, planned
    And the expense "Internet" of R$ 120.00 in account "Nubank" on 2026-03-20, planned
    And the expense "Groceries" of R$ 300.00 in account "Nubank" on 2026-03-08, confirmed, as daily spending
    And the expense "Market" of R$ 60.00 in account "Wallet" on 2026-03-22, planned, as daily spending
    And the purchase "Restaurant" of R$ 140.00 on card "Black" on 2026-03-14, as daily spending
    And the purchase "Gift" of R$ 250.00 on card "Purple" on 2026-03-28
    And the transfer "Save" of R$ 1,000.00 from account "Nubank" to account "Reserve" on 2026-03-06, confirmed
    And the transfer "Extra Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-30, planned

  @IND-11 @IND-1 @IND-2 @IND-3 @IND-4 @IND-5 @IND-6 @IND-7 @IND-9 @STA-6
  Scenario: The realized version of the current month uses only confirmed entries with accrual up to today
    Then the expense "Electricity" is "overdue"
    And the purchase "Restaurant" is "confirmed"
    And the purchase "Gift" is "planned"
    And the realized indicators for 2026-03 are:
      | indicator      | amount      |
      | Inflows        | R$ 6,000.00 |
      | Outflows       | R$ 2,200.00 |
      | Daily spending | R$ 440.00   |
      | Total outflows | R$ 2,640.00 |
      | Performance    | R$ 3,360.00 |
      | Saved          | R$ 1,000.00 |
      | savings rate   | 16.7%       |
      | Daily average  | R$ 29.33    |

  @IND-11 @IND-1 @IND-2 @IND-3 @IND-4 @IND-5 @IND-6 @IND-7 @IND-9 @STA-3
  Scenario: The forecast version of the current month adds up all entries, including overdue ones
    Then the forecast indicators for 2026-03 are:
      | indicator      | amount      |
      | Inflows        | R$ 6,800.00 |
      | Outflows       | R$ 2,760.00 |
      | Daily spending | R$ 500.00   |
      | Total outflows | R$ 3,260.00 |
      | Performance    | R$ 3,540.00 |
      | Saved          | R$ 1,500.00 |
      | savings rate   | 22.1%       |
      | Daily average  | R$ 16.13    |

  @IND-11 @DIA-5
  Scenario: The daily reserve does not count in any indicator
    Then the daily reserve on 2026-03-16 is R$ 50.00
    And the forecast Daily spending for 2026-03 is R$ 500.00
    And the forecast Daily spending list for 2026-03 shows exactly "Groceries, Restaurant, Market"

  @INV-8 @IND-5
  Scenario: INV-8 holds in both versions of the current month
    Then the realized Performance for 2026-03 is R$ 6,000.00 − R$ 2,200.00 − R$ 440.00 = R$ 3,360.00
    And the forecast Performance for 2026-03 is R$ 6,800.00 − R$ 2,760.00 − R$ 500.00 = R$ 3,540.00

  @TAG-9 @IND-11 @INV-8
  Scenario: The tag report uses the same realized/forecast selector
    Then the realized tag report for 2026-03 shows:
      | tag      | expenses    | income      |
      | Untagged | R$ 2,640.00 | R$ 6,000.00 |
    And the forecast tag report for 2026-03 shows:
      | tag      | expenses    | income      |
      | Untagged | R$ 3,260.00 | R$ 6,800.00 |

  @IND-11 @STA-5
  Scenario: Confirming a planned entry moves it to realized
    When I confirm the expense "Electricity" with amount R$ 203.40 on 2026-03-14
    Then the realized Outflows for 2026-03 are R$ 2,403.40
    And the forecast Outflows for 2026-03 are R$ 2,773.40

  @IND-11 @IND-9
  Scenario: A future month has zero realized, forecast with the scheduled entries and no daily average
    Given the income "April Salary" of R$ 6,000.00 in account "Nubank" on 2026-04-05, planned
    And the expense "April Rent" of R$ 2,200.00 in account "Nubank" on 2026-04-10, planned
    Then the realized Inflows for 2026-04 are R$ 0.00
    And the forecast Inflows for 2026-04 are R$ 6,000.00
    And the forecast Performance for 2026-04 is R$ 3,800.00
    And the realized Daily average for 2026-04 is not shown
    And the forecast Daily average for 2026-04 is R$ 0.00
