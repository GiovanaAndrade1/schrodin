Feature: Installment purchase editing
  Background:
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01

  @PAR-4 @PAR-3
  Scenario: The title applies to all installments even after a closed statement
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the title of the purchase "TV" to "Television"
    Then installment 1 appears as "Television (1/10)"
    And installment 10 appears as "Television (10/10)"

  @PAR-4 @LAN-6
  Scenario: The daily spending flag and tags apply to all installments
    Given today is 2026-05-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the purchase "TV" checking daily spending and with the tags "household"
    Then the 10 installments of the purchase "TV" are daily spending and have the tags "household"

  @PAR-4 @PAR-6
  Scenario: Changing the amount with all statements open recalculates the installments
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the total amount of the purchase "TV" to R$ 3,600.00
    Then the 10 installments of the purchase "TV" are R$ 360.00
    And the available limit of card "Purple" is R$ 1,400.00

  @PAR-4 @PAR-2 @INV-4
  Scenario: Changing the total redoes the rounding
    Given today is 2026-03-15
    And the purchase "Sofa" of R$ 1,000.00 on card "Purple" on 2026-03-15 in 3 installments
    When I edit the total amount of the purchase "Sofa" to R$ 1,000.01
    Then the installments of the purchase "Sofa" are R$ 333.35, R$ 333.33 and R$ 333.33
    And the sum of the installments of the purchase "Sofa" is R$ 1,000.01

  @PAR-4 @GER-11
  Scenario: Increasing the number of installments
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the number of installments of the purchase "TV" to 12
    Then the purchase "TV" has 12 installments of R$ 250.00, in the statements from 2026-04 to 2027-03
    And each installment of the purchase "TV" has a unique identity "purchase + no.", from 1 to 12

  @PAR-4 @GER-11
  Scenario: Reducing the number of installments removes the last ones
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the number of installments of the purchase "TV" to 8
    Then the purchase "TV" has 8 installments of R$ 375.00, in the statements from 2026-04 to 2026-11
    And installments 9 and 10 of the purchase "TV" do not exist

  @PAR-4 @LAN-8
  Scenario: Changing the card reallocates all installments
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the card of the purchase "TV" to "Black"
    Then the installments of the purchase "TV" are in the statements from 2026-04 to 2027-01 of card "Black"
    And the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Black" is R$ 7,000.00

  @PAR-4 @error @edge
  Scenario Outline: Amount, N, date and card lock when the first statement closes
    Given today is <today>
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit <field> of the purchase "TV"
    Then <result>

    Examples:
      | today      | field                            | result                                                                                                                                                                  |
      | 2026-04-02 | the total amount to R$ 3,600.00  | the 10 installments of the purchase "TV" are R$ 360.00                                                                                                                  |
      | 2026-04-03 | the total amount to R$ 3,600.00  | the operation is blocked with the message "One installment is already in a closed statement. Cancel the purchase or close the remaining installments and add it again." |
      | 2026-04-03 | the number of installments to 12 | the operation is blocked with the message "One installment is already in a closed statement. Cancel the purchase or close the remaining installments and add it again." |
      | 2026-04-03 | the date to 2026-03-12           | the operation is blocked with the message "One installment is already in a closed statement. Cancel the purchase or close the remaining installments and add it again." |
      | 2026-04-03 | the card to "Black"              | the operation is blocked with the message "One installment is already in a closed statement. Cancel the purchase or close the remaining installments and add it again." |

  @PAR-4 @error
  Scenario: In an account, a confirmed installment locks the amount but not the title
    Given today is 2026-04-12
    And the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-04-10
    And installment 1/3 of the expense "Course" is "confirmed"
    When I edit the total amount of the expense "Course" to R$ 1,200.00
    Then the operation is blocked with the message "One installment has already been confirmed. Close the remaining installments and add it again."
    When I edit the title of the expense "Course" to "English"
    Then the 3 installments of the expense "Course" appear as "English (k/3)"

  @PAR-4 @FAT-12 @edge
  Scenario: Changing the date to an already closed cycle warns and locks the purchase
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I edit the purchase "TV" to date 2026-03-02
    Then I see the warning "this changes a statement that has already closed"
    And the installments of the purchase "TV" are in the statements from 2026-03 to 2026-12 of card "Purple"
    And the amount of the purchase "TV" can no longer be edited

  @PAR-4 @LAN-8
  Scenario: Editing an installment edits the whole purchase, without asking for a scope
    Given today is 2026-03-15
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I open installment 3/10 of the purchase "TV" to edit the amount
    Then the app does not ask for a scope
    And the edited field is the amount of the purchase "TV" (total R$ 3,000.00 or installment R$ 300.00)
