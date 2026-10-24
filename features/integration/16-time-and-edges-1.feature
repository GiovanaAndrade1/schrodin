Feature: Year rollover with Black

  Background:
    Given today is 2026-12-27
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-12-01
    And "Nubank" is the default account
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-12-01
    And the daily amount is R$ 20.00 since 2026-12-01
    And the projection horizon is 2 months
    And the recurring income "Salary" of R$ 4,000.00 in account "Nubank", monthly, starting 2027-01-05, with no end
    And the purchase "Supper" of R$ 400.00 on card "Black" on 2026-12-27
    And the purchase "Trip" of R$ 1,200.00 on card "Black" on 2026-12-28 in 2 installments

  @integration @PRJ-4 @FAT-0 @FAT-1 @FAT-3 @PAR-1 @STA-6 @LIM-3 @IND-11 @PRJ-3 @PRJ-7 @GER-12
  Scenario: Statement, installments, projection and indicators across the year
    Then the purchase "Supper" is in the 2027-01 statement of card "Black"
    And the 2027-01 statement of card "Black" closes on 2026-12-28 and is due on 2027-01-05
    And the 2027-01 statement of card "Black" has the label "January statement" and its identity is card + cycle sequence number, not the month
    And the installments of the purchase "Trip" are:
      | k | amount    | statement | due date   | accrual | status  |
      | 1 | R$ 600.00 | 2027-02   | 2027-02-05 | 2026-12 | planned |
      | 2 | R$ 600.00 | 2027-03   | 2027-03-05 | 2027-01 | planned |
    And the available limit of card "Black" is R$ 9,600.00
    And the available limit of card "Black" after planned entries is R$ 8,400.00
    And the horizon end is 2027-02-27
    And the 2027-03 statement of card "Black" is left out of the projection
    And the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-12-27 | R$ 2,980.00 |
      | 2026-12-31 | R$ 2,900.00 |
      | 2027-01-01 | R$ 2,880.00 |
      | 2027-01-04 | R$ 2,820.00 |
      | 2027-01-05 | R$ 6,400.00 |
      | 2027-02-04 | R$ 5,800.00 |
      | 2027-02-05 | R$ 9,180.00 |
      | 2027-02-27 | R$ 8,740.00 |
    And the lowest future balance is R$ 2,820.00 on 2027-01-04
    And the realized Outflows for 2026-12 are R$ 400.00
    And the forecast Outflows for 2026-12 are R$ 1,000.00
    And the forecast Outflows for 2027-01 are R$ 600.00
    When the day turns to 2026-12-28
    Then the purchase "Trip" is "confirmed", with both installments
    And the available limit of card "Black" is R$ 8,400.00
    And the 2027-01 statement of card "Black" is "closed" with total R$ 400.00
    And the current open statement of card "Black" is the 2027-02 one
    When the day turns to 2027-01-01
    Then the actual balance of account "Nubank" is R$ 3,000.00
    And the projected balance of account "Nubank" on 2027-01-01 is R$ 2,980.00
    And the realized Outflows for 2026-12 are R$ 1,000.00
    And the realized Outflows for 2027-01 are R$ 0.00
    And the forecast Outflows for 2027-01 are R$ 600.00
