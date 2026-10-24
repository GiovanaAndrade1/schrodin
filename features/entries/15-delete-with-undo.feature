Feature: Entry deletion with confirmation and undo

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed

  @GER-5
  Scenario: Deleting asks for confirmation and recalculates the balance
    When I delete the expense "Groceries"
    Then I see the confirmation prompt "Delete 'Groceries'?"
    When I confirm the deletion
    Then the expense "Groceries" does not exist
    And the actual balance of account "Nubank" is R$ 1,000.00
    And I see the option "Undo"

  @GER-5
  Scenario: Cancelling the confirmation does not delete
    When I delete the expense "Groceries"
    And I cancel the deletion
    Then there is the expense "Groceries"
    And the actual balance of account "Nubank" is R$ 880.00

  @GER-5 @GER-6
  Scenario: Undo restores the same entry, with the same id and createdAt
    Given the expense "Groceries" was created on 2026-03-15 08:00
    When I delete the expense "Groceries" and confirm
    And I tap "Undo" after 4 seconds
    Then there is the expense "Groceries" of R$ 120.00 on 2026-03-15, confirmed, with the same id as before
    And the expense "Groceries" shows "Created on 2026-03-15 08:00"
    And the actual balance of account "Nubank" is R$ 880.00

  @GER-5 @edge
  Scenario: After 5 seconds, undo is no longer possible
    When I delete the expense "Groceries" and confirm
    And 6 seconds pass
    Then I do not see the option "Undo"
    And the expense "Groceries" does not exist

  @GER-5 @TRF-2
  Scenario: Undoing a transfer deletion restores both sides
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I delete the transfer "Change" and confirm
    And I tap "Undo" after 2 seconds
    Then the actual balance of account "Nubank" is R$ 780.00
    And the actual balance of account "Wallet" is R$ 300.00

  @GER-5 @EST-4
  Scenario: Deleting a refund frees the purchase cap
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    When I delete the refund "Sneakers" and confirm
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the available limit of card "Purple" is R$ 4,700.00
    And I can add the refund "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-15 linked to the purchase "Sneakers"

  @GER-5 @EST-4
  Scenario: Deleting a purchase with a linked refund also deletes the refund, with a warning
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    When I delete the purchase "Sneakers"
    Then I see the confirmation prompt "Delete 'Sneakers'? 1 linked refund will also be deleted"
    When I confirm the deletion
    Then there is no refund linked to the purchase "Sneakers"
    And the available limit of card "Purple" is R$ 5,000.00

  @GER-5 @EST-7 @EST-4
  Scenario: Deleting an expense with a linked account refund also deletes the account refund
    Given the expense "Headphones" of R$ 200.00 in account "Nubank" on 2026-03-05, confirmed
    And the account refund "Headphones" of R$ 200.00 in account "Nubank" on 2026-03-12 linked to the expense "Headphones"
    When I delete the expense "Headphones" and confirm
    Then there is no account refund linked to the expense "Headphones"
    And the actual balance of account "Nubank" is R$ 880.00
