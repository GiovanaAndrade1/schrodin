Feature: Invariants hold after any sequence of operations
  Property test: each sequence runs from the same state and
  all invariants are checked after EACH operation, not only at the end.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 1,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months
    And the purchase "TV" of R$ 1,200.00 on card "Purple" on 2026-02-10 in 3 installments with the tag "household"
    And the payment of R$ 400.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10 with the tag "leisure"
    And the operations catalog:
      | id  | operation                                                                             |
      | O1  | add the purchase "Groceries" of R$ 100.00 to card "Purple" on 2026-03-15              |
      | O2  | add the refund of R$ 300.00 on 2026-03-15 linked to the purchase "Sneakers"           |
      | O3  | cancel the purchase "TV"                                                              |
      | O4  | pay R$ 700.00 of the 2026-04 statement of card "Purple" from account "Nubank" today   |
      | O5  | pay R$ 1,000.00 of the 2026-04 statement of card "Purple" from account "Nubank" today |
      | O6  | transfer R$ 500.00 from account "Nubank" to account "Reserve" today, confirmed        |
      | O7  | adjust the balance of account "Nubank" to R$ 1,000.00, proceeding despite warnings    |
      | O8  | delete the payment of R$ 400.00 of the 2026-03 statement                              |
      | O9  | answer "I didn't pay" for the 2026-03 statement                                       |
      | O10 | change the closing day of card "Purple" to 20                                         |
      | O11 | run installment and occurrence generation again, on two devices                       |
      | O12 | withdraw all the credit of card "Purple" to account "Nubank"                          |
      | O13 | turn the day to 2026-03-16                                                            |

  @integration @INV-1 @INV-2 @INV-3 @INV-4 @INV-5 @INV-6 @INV-7 @INV-8 @INV-10 @EST-5 @FAT-9 @FAT-10 @CAR-5 @TRF-8 @AJU-1 @GER-11
  Scenario Outline: Sequence <sequence>
    When I run the operations <sequence>, in order
    Then after each operation the following hold:
      | invariant | check                                                                                                                                                                                                                                |
      | INV-1     | the actual balance of each account, recalculated from scratch, equals the displayed one                                                                                                                                              |
      | INV-2     | every transfer sums to zero across both sides; the total in accounts only changed through income, account refund, account expense, adjustment or transfer to/from a card (statement payment, withdrawal)                             |
      | INV-3     | every single-payment purchase and every confirmed installment is in exactly one statement, except cancelled installments (EST-5)                                                                                                     |
      | INV-4     | the sum of the installments of "TV", including cancelled ones, is R$ 1,200.00                                                                                                                                                        |
      | INV-5     | the total debt of "Purple" equals the sum of the outstanding amounts of all statements, confirmed entries only (credit counts as negative)                                                                                           |
      | INV-6     | no confirmed entry has a future date (there is no time zone change in these sequences, so the GER-3 exception does not apply)                                                                                                        |
      | INV-7     | no entry has a date before the account's opening balance (2026-01-01) or the card's start date (2026-01-01); there are no CAR-9 entries here                                                                                         |
      | INV-8     | 2026-03 Performance = Inflows − Outflows − Daily spending; since no entry has more than one tag, Σ expenses of the tag report (with "Untagged") = Total outflows and Σ income = Inflows, in the same version (realized and forecast) |
      | INV-10    | generating occurrences/installments again changes no number in this table and creates no entry                                                                                                                                       |
    And in the end the actual balance of account "Nubank" is <nubank>
    And the actual balance of account "Reserve" is <reserve>
    And the total debt of card "Purple" is <debt>
    And the available limit of card "Purple" is <available>
    And the outstanding amounts of the statements of card "Purple" are 2026-03: <March>, 2026-04: <April>, 2026-05: <May>

    Examples:
      | sequence             | nubank      | reserve     | debt        | available   | March   | April       | May       |
      | (none)               | R$ 1,600.00 | R$ 1,000.00 | R$ 1,100.00 | R$ 3,900.00 | R$ 0.00 | R$ 700.00   | R$ 400.00 |
      | O1, O2, O4           | R$ 900.00   | R$ 1,000.00 | R$ 200.00   | R$ 4,800.00 | R$ 0.00 | -R$ 200.00  | R$ 400.00 |
      | O3, O5, O12          | R$ 1,700.00 | R$ 1,000.00 | R$ 0.00     | R$ 5,000.00 | R$ 0.00 | R$ 0.00     | R$ 0.00   |
      | O8, O9, O13          | R$ 2,000.00 | R$ 1,000.00 | R$ 1,500.00 | R$ 3,500.00 | R$ 0.00 | R$ 1,100.00 | R$ 400.00 |
      | O6, O7, O1, O10, O11 | R$ 1,000.00 | R$ 1,500.00 | R$ 1,200.00 | R$ 3,800.00 | R$ 0.00 | R$ 800.00   | R$ 400.00 |
      | O2, O3               | R$ 1,600.00 | R$ 1,000.00 | -R$ 400.00  | R$ 5,400.00 | R$ 0.00 | -R$ 400.00  | R$ 0.00   |
      | O4, O8, O9           | R$ 1,300.00 | R$ 1,000.00 | R$ 800.00   | R$ 4,200.00 | R$ 0.00 | R$ 400.00   | R$ 400.00 |
      | O11                  | R$ 1,600.00 | R$ 1,000.00 | R$ 1,100.00 | R$ 3,900.00 | R$ 0.00 | R$ 700.00   | R$ 400.00 |

  @integration @INV-2 @FAT-7 @TRF-8 @TRF-7
  Scenario: The total in accounts changes with statement payment and withdrawal, which are transfers to/from a card
    When I run the operations O3, O5, O12, in order
    Then the total in accounts changed by -R$ 1,000.00 with O5 (statement payment) and by +R$ 1,100.00 with O12 (withdrawal)
    And the consolidated actual balance went up by R$ 1,100.00 with O12, because "Nubank" is spending
    And the total in accounts minus the card debt changed by R$ 0.00 in O5 and in O12

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

  @integration @INV-6 @STA-6 @STA-3 @STA-8 @GER-3
  Scenario: No confirmed entry with a future date across midnight
    Given today is 2026-03-15
    And the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the card "Blue" with limit R$ 3,000.00, closing day 3, due day 10, payment account "Itaú" and start date 2026-03-01
    And the purchase "Concert" of R$ 200.00 on card "Blue" on 2026-03-16
    And the expense "Electricity" of R$ 150.00 in account "Itaú" on 2026-03-16, planned
    And the expense "Coffee" of R$ 10.00 in account "Itaú" on 2026-03-15, confirmed
    Then no confirmed entry has a date after 2026-03-15
    When the day turns to 2026-03-16
    Then the purchase "Concert" is "confirmed"
    And the expense "Electricity" is "planned", not "overdue"
    And no confirmed entry has a date after 2026-03-16
    When I edit the date of the expense "Coffee" to 2026-03-17
    Then the expense "Coffee" is "planned" and I see the warning that it went back to planned
    And no confirmed entry has a date after 2026-03-16
