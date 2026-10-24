Feature: Editing, deleting or unconfirming the payment of a closed, rolled-over or credit-passing statement
  The passed credit is removed from the next one, which may reopen the outstanding amount.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-12 @FAT-10 @LIM-1
  Scenario: Deleting a payment that passed credit removes the credit from the next one
    Given today is 2026-04-05
    And the payment of R$ 350.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05, confirmed
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-04-05
    And the 2026-05 statement of card "Purple" has total R$ 50.00 and outstanding R$ 50.00
    When I delete the payment of the 2026-04 statement of card "Purple"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-04 statement of card "Purple" is "closed"
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 0.00
    And the 2026-05 statement of card "Purple" has total R$ 100.00 and outstanding R$ 100.00
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the total debt of card "Purple" is R$ 400.00

  @FAT-12 @FAT-10 @edge
  Scenario Outline: The amount of a payment that passed credit is edited
    Given today is 2026-04-05
    And the payment of R$ 350.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05, confirmed
    When I edit the payment of the 2026-04 statement of card "Purple" to <new amount>
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding <outstanding>
    And the 2026-04 statement of card "Purple" is "<status>"
    And the 2026-05 statement of card "Purple" has carried-over credit <credit>

    Examples:
      | new amount | outstanding | status | credit   |
      | R$ 320.00  | R$ 0.00     | paid   | R$ 20.00 |
      | R$ 300.00  | R$ 0.00     | paid   | R$ 0.00  |
      | R$ 250.00  | R$ 50.00    | closed | R$ 0.00  |

  @FAT-12 @FAT-9
  Scenario: Deleting a partial payment of a rolled-over statement increases the carried-over balance of the next one
    Given today is 2026-04-11
    And the payment of R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 200.00
    When I delete the payment of the 2026-04 statement of card "Purple"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" is "rolled over"
    And the 2026-04 statement of card "Purple" has outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 300.00
    And the total debt of card "Purple" is R$ 300.00
