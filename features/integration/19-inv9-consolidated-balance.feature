Feature: INV-9, today's projection equals the consolidated actual balance

  Background:
    Given today is 2026-03-15

  @integration @INV-9 @PRJ-2 @PRJ-5 @FAT-6 @DIA-5
  Scenario Outline: Today's projection equals the consolidated actual balance when nothing is pending
    Given today is 2026-03-15
    And the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Safe" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And the card "Blue" with limit R$ 3,000.00, closing day 3, due day 10, payment account "Itaú" and start date 2026-03-01
    And the daily amount is R$ 0.00 since 2026-03-01
    And <change>
    Then the consolidated actual balance is <actual>
    And the consolidated projected balance on 2026-03-15 is <today>
    And the preconditions of INV-9 <condition>

    Examples:
      | change                                                                                                                                                                          | actual      | today       | condition                           |
      | nothing else                                                                                                                                                                    | R$ 1,200.00 | R$ 1,200.00 | hold                                |
      | the transfer "Save" of R$ 500.00 from account "Itaú" to account "Safe" on 2026-03-15, confirmed                                                                                 | R$ 700.00   | R$ 700.00   | hold                                |
      | the purchase "Book" of R$ 300.00 on card "Blue" on 2026-03-01 and the payment of R$ 300.00 of the 2026-03 statement of card "Blue" from account "Itaú" on 2026-03-10, confirmed | R$ 900.00   | R$ 900.00   | hold                                |
      | the purchase "Book" of R$ 300.00 on card "Blue" on 2026-03-15                                                                                                                   | R$ 1,200.00 | R$ 1,200.00 | do not hold (outstanding statement) |
      | the expense "Electricity" of R$ 100.00 in account "Itaú" on 2026-03-15, planned                                                                                                 | R$ 1,200.00 | R$ 1,100.00 | do not hold (planned)               |
      | the daily amount changes to R$ 50.00 from 2026-03-15                                                                                                                            | R$ 1,200.00 | R$ 1,150.00 | do not hold (daily spending)        |
