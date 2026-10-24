Feature: Cancelling an installment purchase and closing the remaining installments (entry view)

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the purchase "Fridge" of R$ 1,000.00 on card "Purple" on 2026-01-10 in 3 installments
    And the installments of the purchase "Fridge" are:
      | k | amount    | statement |
      | 1 | R$ 333.34 | 2026-02   |
      | 2 | R$ 333.33 | 2026-03   |
      | 3 | R$ 333.33 | 2026-04   |

  @EST-5 @LIM-1 @FAT-10 @INV-4
  Scenario: Cancelling with installments in closed statements creates a refund for their sum
    Given the payment of R$ 333.34 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed
    And the payment of R$ 333.33 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the available limit of card "Purple" is R$ 4,666.67
    When I cancel the purchase "Fridge"
    Then the purchase "Fridge" is "cancelled"
    And installment 3 of the purchase "Fridge" is "cancelled"
    And the sum of the installments of the purchase "Fridge", counting the cancelled ones, is R$ 1,000.00
    And the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 666.67 on 2026-03-15
    And the 2026-04 statement of card "Purple" has total -R$ 666.67 and outstanding -R$ 666.67
    And the available limit of card "Purple" is R$ 5,666.67

  @EST-5 @EST-4 @edge
  Scenario Outline: Cancelling settles the difference with the refunds the purchase already had
    Given the refund "Discount" of R$ <previous> on card "Purple" on 2026-02-15 linked to the purchase "Fridge"
    When I cancel the purchase "Fridge"
    Then <settlement>
    And the purchase "Fridge" costs R$ 0.00 net

    Examples:
      | previous | settlement                                                                                                       |
      | 100.00   | the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 566.67 on 2026-03-15   |
      | 666.67   | the 2026-04 statement of card "Purple" has no cancellation settlement                                            |
      | 700.00   | the 2026-04 statement of card "Purple" has the linked charge "Cancellation settlement" of R$ 33.33 on 2026-03-15 |

  @EST-5 @EST-3 @IND-2 @edge
  Scenario Outline: In the indicators, the cancellation settlement goes into the current month
    Given the refund "Discount" of R$ <previous> on card "Purple" on 2026-02-15 linked to the purchase "Fridge"
    When I cancel the purchase "Fridge"
    Then the realized Outflows for 2026-01 are R$ 333.34
    And the realized Outflows for 2026-02 are <February>
    And the realized Outflows for 2026-03 are <March>

    Examples:
      | previous | February   | March      |
      | 100.00   | R$ 233.33  | -R$ 566.67 |
      | 700.00   | -R$ 366.67 | R$ 33.33   |

  @EST-5 @edge
  Scenario: Cancelling with all installments in open or future statements creates no refund
    Given the purchase "Headphones" of R$ 600.00 on card "Purple" on 2026-03-10 in 3 installments
    When I cancel the purchase "Headphones"
    Then the 3 installments of the purchase "Headphones" are "cancelled"
    And there is no refund linked to the purchase "Headphones"
    And the available limit of card "Purple" is R$ 4,000.00

  @EST-6 @LIM-1
  Scenario: Closing the remaining installments on the card cancels only the future ones, with no refund
    Given the payment of R$ 333.34 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed
    And the payment of R$ 333.33 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    When I close the remaining installments of the purchase "Fridge"
    Then installment 3 of the purchase "Fridge" is "cancelled"
    And installments 1 and 2 of the purchase "Fridge" are still active
    And there is no refund linked to the purchase "Fridge"
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00

  @EST-6 @PAR-8 @CON-4
  Scenario: Closing the remaining installments in an account cancels the planned ones and keeps the confirmed ones
    Given the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments starting 2026-03-10
    And installment 1 of the expense "Course" is "confirmed" on 2026-03-10 with R$ 300.00
    And installments 2 and 3 of the expense "Course" are "planned" on 2026-04-10 and 2026-05-10
    When I close the remaining installments of the expense "Course"
    Then installments 2 and 3 of the expense "Course" are "cancelled"
    And the actual balance of account "Nubank" is R$ 4,700.00
    And the expense "Course" has no planned installments
