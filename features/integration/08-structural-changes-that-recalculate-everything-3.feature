Feature: Changing the card's closing day

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the daily budget source is card "Purple"
    And the projection horizon is 2 months
    And the purchase "TV" of R$ 1,200.00 on card "Purple" on 2026-03-05 in 3 installments
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-03-12, moved to the 2026-05 statement
    And the purchase "Gift" of R$ 200.00 on card "Purple" on 2026-03-25

  @integration @CAR-5 @FAT-0 @FAT-1 @FAT-2 @FAT-3 @FAT-6 @FAT-13 @PAR-1 @DIA-10 @LIM-1 @LIM-3 @PRJ-3 @PRJ-7 @IND-2
  Scenario: Moving the closing from day 3 to day 20 reallocates purchases, installments and the daily reserve
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 1,850.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 2,000.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 1,150.00
    And the lowest future balance is R$ 1,150.00 on 2026-05-10
    When I change the closing day of card "Purple" to 20
    Then the app shows before confirming:
      | statement | cycle                    | due date   |
      | 2026-04   | 2026-03-03 to 2026-03-19 | 2026-04-10 |
      | 2026-05   | 2026-03-20 to 2026-04-19 | 2026-05-10 |
      | 2026-06   | 2026-04-20 to 2026-05-19 | 2026-06-10 |
    When I confirm the change
    Then the 2026-03 statement of card "Purple" still closes on 2026-03-03
    And the purchases look like this:
      | purchase | statement | reason                                              |
      | TV (1/3) | 2026-04   | installment 1 in the statement of the purchase date |
      | TV (2/3) | 2026-05   | one installment per consecutive statement           |
      | TV (3/3) | 2026-06   | one installment per consecutive statement           |
      | Sneakers | 2026-04   | 2026-03-10 is in the new April cycle                |
      | Book     | 2026-05   | pinned, not reallocated                             |
      | Gift     | 2026-05   | 2026-03-25 moved to the May cycle                   |
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 950.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 2,250.00 on 2026-05-10
    And the reserve for the days from 2026-04-20 to 2026-05-02, R$ 650.00, went to the 2026-06 statement, beyond the horizon
    And next to the lowest balance "R$ 1,300.00 of daily spending in statements beyond the horizon" appears, which used to be R$ 650.00
    And the statements keep the same identities (card + cycle number)
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 4,050.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 1,800.00
    And the lowest future balance is R$ 1,800.00 on 2026-05-10
    And the available limit of card "Purple" is R$ 3,400.00
    And the available limit of card "Purple" after planned entries is R$ 3,200.00
    And the forecast Outflows for 2026-03 are still R$ 1,000.00
