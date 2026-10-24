Feature: Installment purchase deletion or cancellation
  Background:
    Given the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @PAR-7 @LIM-1
  Scenario: Deleting a purchase with no closed statement removes all installments
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I delete the purchase "TV"
    Then there is no installment of the purchase "TV"
    And the available limit of card "Purple" is R$ 5,000.00

  @PAR-7 @FAT-12 @FAT-10
  Scenario: Deleting a purchase with installments in paid statements warns and generates credit
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And the payment of R$ 300.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-08, confirmed
    When I delete the purchase "TV"
    Then I see the warning "this changes a statement that has already closed"
    And there is no installment of the purchase "TV"
    And the card "Purple" has credit of R$ 600.00 that offsets the 2026-06 statement
    And the available limit of card "Purple" is R$ 5,600.00

  @PAR-7 @GER-5 @GER-11 @INV-10
  Scenario: Undoing the deletion brings back the same installments
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I delete the purchase "TV"
    And I tap "Undo" after 2 seconds
    Then the purchase "TV" has 10 installments of R$ 300.00, in the statements from 2026-04 to 2027-01
    And each installment of the purchase "TV" has the same identity "purchase + no." as before

  @PAR-7 @PAR-8 @INV-1
  Scenario: Deleting account installments with a confirmed installment
    Given today is 2026-04-12
    And the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-04-10
    And installment 1/3 of the expense "Course" is "confirmed"
    When I delete the expense "Course"
    Then I see the warning "1 already confirmed installment will be deleted and the balance of account Nubank will change"
    And there is no installment of the expense "Course"
    And the actual balance of account "Nubank" is R$ 5,000.00

  @EST-5 @INV-4 @LIM-1 @FAT-10
  Scenario: Cancelling the purchase refunds the installments of closed statements
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And the payment of R$ 300.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-08, confirmed
    When I cancel the purchase "TV"
    Then installments 3 to 10 of the purchase "TV" are "cancelled" and are not in any statement
    And the 2026-06 statement of card "Purple" has a refund linked to the purchase "TV" of R$ 600.00 on 2026-05-15
    And the purchase "TV" is "cancelled"
    And the sum of the installments of the purchase "TV", counting the cancelled ones, is R$ 3,000.00
    And the available limit of card "Purple" is R$ 5,600.00

  @EST-5 @LIM-1 @INV-4
  Scenario: Cancelling a purchase with no closed statement cancels everything with no refund
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I cancel the purchase "TV"
    Then no statement has an installment of the purchase "TV"
    And there is no refund linked to the purchase "TV"
    And the available limit of card "Purple" is R$ 5,000.00

  @EST-5 @LIM-3
  Scenario: Cancelling a planned installment purchase removes all installments
    Given today is 2026-03-15
    And the purchase "Laptop" of R$ 4,000.00 on card "Purple" on 2026-04-20 in 10 installments
    When I cancel the purchase "Laptop"
    Then no statement has an installment of the purchase "Laptop"
    And the available limit of card "Purple" after planned entries is R$ 5,000.00

  @EST-6 @PAR-4 @PAR-8 @INV-4
  Scenario: Closing the remaining installments in an account keeps the confirmed ones
    Given today is 2026-04-12
    And the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-04-10
    And installment 1/3 of the expense "Course" is "confirmed"
    When I close the remaining installments of the expense "Course"
    Then installment 1/3 of the expense "Course" is still "confirmed"
    And installments 2/3 and 3/3 of the expense "Course" are "cancelled"
    And the sum of the installments of the expense "Course", counting the cancelled ones, is R$ 900.00
    And there are no overdue entries
    And the actual balance of account "Nubank" is R$ 4,700.00

  @EST-6 @LIM-1 @INV-4
  Scenario: Closing the remaining installments on a card does not generate a refund
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And the payment of R$ 300.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-08, confirmed
    When I close the remaining installments of the purchase "TV"
    Then installments 3 to 10 of the purchase "TV" are "cancelled"
    And installments 1 and 2 are still in the 2026-04 and 2026-05 statements
    And there is no refund linked to the purchase "TV"
    And the sum of the installments of the purchase "TV", counting the cancelled ones, is R$ 3,000.00
    And the available limit of card "Purple" is R$ 5,000.00

  @EST-5 @EST-4
  Scenario Outline: The cancellation refund deducts already linked refunds
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the refund "TV" of <previous> on card "Purple" on 2026-04-20 linked to the purchase "TV"
    When I cancel the purchase "TV"
    Then <result>
    And the purchase "TV" costs R$ 0.00 net

    Examples:
      | previous  | result                                                                                                            |
      | R$ 100.00 | the 2026-06 statement of card "Purple" has a refund linked to the purchase "TV" of R$ 500.00 on 2026-05-15        |
      | R$ 600.00 | the 2026-06 statement of card "Purple" has no cancellation settlement                                             |
      | R$ 700.00 | the 2026-06 statement of card "Purple" has the linked charge "Cancellation settlement" of R$ 100.00 on 2026-05-15 |

  @PAR-7 @EST-4 @PAR-5
  Scenario: Deleting the purchase deletes the prepayment discount refund
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And I prepaid 1 installment of the purchase "TV" with a discount of R$ 10.00
    When I delete the purchase "TV"
    Then I see the confirmation prompt "Delete 'TV'? 1 linked refund will also be deleted"
    When I confirm the deletion
    Then there is no installment of the purchase "TV"
    And there is no refund linked to the purchase "TV"
    And the available limit of card "Purple" is R$ 5,000.00
