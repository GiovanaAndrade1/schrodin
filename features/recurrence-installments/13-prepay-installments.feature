Feature: Card installment prepayment
  Background:
    Given today is 2026-05-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And the payment of R$ 300.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-08, confirmed
    And the available limit of card "Purple" is R$ 2,600.00

  @PAR-5 @PAR-3
  Scenario: Prepaying moves the last installments to the current open statement
    When I prepay 2 installments of the purchase "TV" with no discount
    Then installments 3, 9 and 10 of the purchase "TV" are in the 2026-06 statement of card "Purple"
    And the 2026-06 statement of card "Purple" has total R$ 900.00
    And the 2026-12 and 2027-01 statements of card "Purple" have no installment of the purchase "TV"
    And installment 10 still appears as "TV (10/10)"
    And the accrual date of installment 9 is still 2026-11-10 and that of installment 10 is still 2026-12-10
    And the available limit of card "Purple" is R$ 2,600.00

  @PAR-5 @EST-1 @EST-2
  Scenario: The prepayment discount becomes a linked refund
    When I prepay 2 installments of the purchase "TV" with a discount of R$ 30.00
    Then there is the refund "TV Prepayment Discount" of R$ 30.00 on card "Purple" on 2026-05-15 linked to the purchase "TV"
    And the refund is in the 2026-06 statement of card "Purple"
    And the 2026-06 statement of card "Purple" has total R$ 870.00
    And the available limit of card "Purple" is R$ 2,630.00

  @PAR-5 @edge
  Scenario: Prepaying all the remaining ones
    When I prepay 7 installments of the purchase "TV" with no discount
    Then installments 3 to 10 of the purchase "TV" are in the 2026-06 statement of card "Purple"
    And the 2026-06 statement of card "Purple" has total R$ 2,400.00

  @PAR-5 @error @edge
  Scenario: Prepaying more installments than the future ones is rejected
    When I prepay 8 installments of the purchase "TV" with no discount
    Then the operation is blocked with the message "There are only 7 future installments to prepay"

  @PAR-5 @error
  Scenario: A middle installment can't be prepaid
    When I try to prepay only installment 5/10 of the purchase "TV"
    Then the operation is blocked with the message "Installments are prepaid from the last to the first"

  @PAR-5 @error @edge
  Scenario Outline: Discount limited to the sum of the prepaid installments
    When I prepay 2 installments of the purchase "TV" with a discount of <discount>
    Then <result>

    Examples:
      | discount  | result                                                                             |
      | R$ 600.00 | the 2026-06 statement of card "Purple" has total R$ 300.00                         |
      | R$ 600.01 | the operation is blocked with the message "The discount can't exceed R$ 600.00"    |
      | R$ 0,00   | the operation is blocked with the message "The discount must be greater than zero" |

  @PAR-5 @error @edge
  Scenario: With no future installments there is nothing to prepay
    Given today is 2027-01-01
    When I try to prepay installments of the purchase "TV"
    Then the operation is blocked with the message "There are no future installments to prepay"

  @PAR-5 @PAR-8 @error
  Scenario: Account installments do not offer prepayment
    Given the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-06-10
    Then the expense "Course" does not have the option "Prepay installments"
