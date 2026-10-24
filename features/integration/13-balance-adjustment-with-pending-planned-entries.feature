Feature: Balance adjustment and planned entries nobody confirmed

  Background:
    Given today is 2026-03-15
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 1 month

  @integration @AJU-1 @AJU-2 @AJU-3 @STA-5 @IND-1
  Scenario: Following the warning: confirming the overdue entry makes the adjustment unnecessary
    Given the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the income "Salary" of R$ 6,000.00 in account "Nubank" on 2026-03-14, planned
    And the consolidated projected balance on 2026-03-15 is R$ 8,000.00
    When I adjust the balance of account "Nubank" to R$ 8,000.00
    Then I see the warning listing "Salary (2026-03-14) overdue"
    When I confirm the income "Salary" from the warning with amount R$ 6,000.00 on 2026-03-14
    Then the actual balance of account "Nubank" is R$ 8,000.00
    And no adjustment is created, because the difference is zero
    And the consolidated projected balance on 2026-03-15 is R$ 8,000.00
    And the realized Inflows for 2026-03 are R$ 6,000.00
    And the overdue badge shows 0

  @integration @AJU-1 @AJU-3 @AJU-4 @AJU-5 @STA-4 @PRJ-2 @IND-1 @IND-11
  Scenario: Ignoring the warning counts the salary twice in the projection until the adjustment is deleted
    Given the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the income "Salary" of R$ 6,000.00 in account "Nubank" on 2026-03-14, planned
    When I adjust the balance of account "Nubank" to R$ 8,000.00
    And I proceed with the adjustment despite the warning
    Then there is an inflow adjustment of R$ 6,000.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 8,000.00
    And the consolidated projected balance on 2026-03-15 is R$ 14,000.00
    And the realized Inflows for 2026-03 are R$ 0.00
    And the forecast Inflows for 2026-03 are R$ 6,000.00
    And the overdue badge shows 1
    When I confirm the income "Salary" with amount R$ 6,000.00 on 2026-03-14
    Then the actual balance of account "Nubank" is R$ 14,000.00
    And the consolidated projected balance on 2026-03-15 is R$ 14,000.00
    When I delete the adjustment of R$ 6,000.00 from account "Nubank"
    Then the actual balance of account "Nubank" is R$ 8,000.00
    And the consolidated projected balance on 2026-03-15 is R$ 8,000.00
    And the realized Inflows for 2026-03 are R$ 6,000.00

  @integration @AJU-1 @AJU-4 @IND-1 @IND-2 @IND-5 @IND-6 @IND-8 @TAG-9 @TAG-10 @PRJ-7 @TER-2 @INV-8
  Scenario: An adjustment only changes the balance, the projection and the color
    Given the account "Nubank" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the income "Salary" of R$ 3,000.00 in account "Nubank" on 2026-03-05, confirmed, with the tag "salary"
    And the expense "Rent" of R$ 1,800.00 in account "Nubank" on 2026-03-08, confirmed, with the tag "home"
    And the expense "Internet" of R$ 100.00 in account "Nubank" on 2026-03-25, planned, with the tag "home"
    Then the consolidated projected balance on 2026-03-15 is R$ 1,200.00 with color "light green"
    And the lowest future balance is R$ 1,100.00 on 2026-03-25
    When I adjust the balance of account "Nubank" to R$ 900.00
    Then no planned entries warning appears
    And there is an outflow adjustment of R$ 300.00 in account "Nubank" on 2026-03-15, confirmed
    And the 2026-03-15 adjustment of account "Nubank" has no tags
    And the consolidated projected balance on 2026-03-15 is R$ 900.00 with color "yellow"
    And the lowest future balance is R$ 800.00 on 2026-03-25
    And the realized indicators for 2026-03 are still Inflows R$ 3,000.00, Outflows R$ 1,800.00, Daily spending R$ 0.00, Performance R$ 1,200.00 and Saved R$ 0.00
    And the realized tag report for 2026-03 shows:
      | tag    | expenses    | income      |
      | home   | R$ 1,800.00 | R$ 0.00     |
      | salary | R$ 0.00     | R$ 3,000.00 |
    When the day turns to 2026-04-01
    Then the cost of living is R$ 1,800.00

  @integration @AJU-3 @FAT-9 @STA-3 @CAR-3
  Scenario Outline: What triggers the warning before adjusting
    Given the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And <situation>
    When I adjust the balance of account "Nubank" to R$ 1,500.00
    Then <result>

    Examples:
      | situation                                                                                    | result                                                                                                    |
      | the expense "Electricity" of R$ 200.00 in account "Nubank" on 2026-03-14, planned            | I see the warning listing "Electricity (2026-03-14) overdue"                                              |
      | the expense "Electricity" of R$ 200.00 in account "Nubank" on 2026-03-15, planned            | I see the warning listing "Electricity (2026-03-15) due today"                                            |
      | the expense "Electricity" of R$ 200.00 in account "Nubank" on 2026-03-16, planned            | there is an outflow adjustment of R$ 500.00 in account "Nubank" on 2026-03-15, confirmed, with no warning |
      | the card "Purple" paid from account "Nubank" with the 2026-03 statement overdue by R$ 300.00 | I see the warning listing "2026-03 statement of Purple overdue"                                           |
      | the card "Black" paid from account "Itaú" with the 2026-03 statement overdue by R$ 300.00    | there is an outflow adjustment of R$ 500.00 in account "Nubank" on 2026-03-15, confirmed, with no warning |
