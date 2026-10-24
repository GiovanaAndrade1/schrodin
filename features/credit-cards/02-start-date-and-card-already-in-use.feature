Feature: Card start date and starting with a card already in use

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01

  @CAR-8
  Scenario: A start date in the past allows adding old purchases
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-02-01
    And I add the purchase "Dinner" of R$ 200.00 to card "Purple" on 2026-02-20
    Then the purchase "Dinner" is in the 2026-03 statement of card "Purple"

  @CAR-8 @LAN-7 @INV-7 @error @edge
  Scenario Outline: A purchase and a refund cannot be earlier than the start date
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-01
    When I add <entry> of R$ 50.00 to card "Purple" on <date>
    Then <result>

    Examples:
      | entry                      | date       | result                                                                                             |
      | the purchase "Coffee"      | 2026-02-28 | the operation is blocked with the message "The date can't be before the card's start (2026-03-01)" |
      | the purchase "Coffee"      | 2026-03-01 | the purchase "Coffee" is in the 2026-03 statement of card "Purple"                                 |
      | the refund "Reimbursement" | 2026-02-28 | the operation is blocked with the message "The date can't be before the card's start (2026-03-01)" |

  @CAR-8 @error
  Scenario: The start date cannot be in the future
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-16
    Then the operation is blocked with the message "The start date can't be in the future"

  @CAR-8 @CON-7 @error
  Scenario: Changing the start date to after existing entries is blocked
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I change the start date of card "Purple" to 2026-03-01
    Then the operation is blocked with the message "There are entries before the new start date"
    And I see the list of conflicts with "Dinner"
    And the start date of card "Purple" is 2026-01-01

  @CAR-8
  Scenario: Changing the start date without conflict is allowed
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I change the start date of card "Purple" to 2026-03-10
    Then the start date of card "Purple" is 2026-03-10

  @CAR-8 @FAT-7 @error
  Scenario: A statement payment cannot be earlier than the start date
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-02-28
    Then the operation is blocked with the message "The date can't be before the card's start (2026-03-01)"

  @CAR-8 @FAT-5
  Scenario: A new card with the default start date does not create old overdue statements
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    Then the card "Purple" has no "overdue" statement
    And there is no question "Did you pay?" for any statement of card "Purple"

  @CAR-9 @FAT-4 @LIM-1
  Scenario: The card starts with the balance already spent on the current statement
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    When I enter the current statement balance of card "Purple" as R$ 450.00
    Then the 2026-04 statement of card "Purple" has the purchase "Pre-app balance" of R$ 450.00 on 2026-03-15
    And the 2026-04 statement of card "Purple" has total R$ 450.00 and outstanding R$ 450.00
    And the available limit of card "Purple" is R$ 4,550.00
    And the realized Outflows for 2026-03 are R$ 0.00
    And the realized tag report for 2026-03 does not show "Pre-app balance"

  @CAR-9 @CAR-8 @FAT-5 @FAT-6
  Scenario: The card starts with a closed statement not yet paid, before the start date
    Given today is 2026-03-05
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-05
    When I enter the closed unpaid statement balance of card "Purple" as R$ 800.00
    Then the 2026-03 statement of card "Purple" has the purchase "Pre-app balance" of R$ 800.00 on 2026-03-02
    And the 2026-03 statement of card "Purple" is "closed"
    And the 2026-03 statement of card "Purple" has total R$ 800.00 and outstanding R$ 800.00
    And the projected balance of account "Nubank" on 2026-03-10 is R$ 200.00
    And the available limit of card "Purple" is R$ 4,200.00

  @CAR-9 @CAR-8 @PAR-1 @LIM-1
  Scenario: The card starts with an ongoing installment purchase, with the original purchase date
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-15
    When I enter the ongoing installment purchase "Fridge" on card "Purple" bought on 2026-01-10, with a total of R$ 1,200.00 in 6 installments, currently at installment 3
    Then the purchase "Fridge" has date 2026-01-10
    And the installments of the purchase "Fridge" are:
      | k | amount    | statement |
      | 3 | R$ 200.00 | 2026-04   |
      | 4 | R$ 200.00 | 2026-05   |
      | 5 | R$ 200.00 | 2026-06   |
      | 6 | R$ 200.00 | 2026-07   |
    And installments 1 and 2 of the purchase "Fridge" are recorded as "pre-app", of R$ 200.00 each, outside any statement
    And the sum of the installments of the purchase "Fridge" is R$ 1,200.00
    And the total debt of card "Purple" is R$ 800.00
    And the available limit of card "Purple" is R$ 4,200.00
    And the realized Outflows for 2026-01 are R$ 0.00
    And the realized Outflows for 2026-02 are R$ 0.00
    And the realized Outflows for 2026-03 are R$ 200.00
