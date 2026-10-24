Feature: Empty statement
  After closing, with no entries in the cycle and total 0: it disappears from the statement list and pending items, with no "Did you pay?". Closed with total < 0 becomes "in credit" (visible); with a purchase and a refund adding up to 0 it becomes "paid". Before closing it is always "open", and the open one with total ≤ 0 still counts in the projection through the FAT-6 formula.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @FAT-11 @FAT-5 @FAT-6
  Scenario: A statement with no purchases is open until it closes and then disappears from the pending items
    Then the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" is "open"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,000.00
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "empty"
    And the 2026-04 statement of card "Purple" does not appear in the statement list
    And the 2026-04 statement of card "Purple" does not appear in the pending items list
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-5 @EST-2 @edge
  Scenario: A purchase and a refund of the same amount leave the statement paid, not empty
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-14 linked to the purchase "Sneakers"
    Then the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" is "open"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "paid"
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-11 @FAT-5 @FAT-6 @FAT-10 @edge
  Scenario: An open statement with a negative total and a planned purchase still generates a derived outflow
    Given the refund "Reimbursement" of R$ 50.00 on card "Purple" on 2026-03-14, unlinked
    And the purchase "Concert" of R$ 120.00 on card "Purple" on 2026-03-20
    Then the purchase "Concert" is "planned"
    And the 2026-04 statement of card "Purple" has total -R$ 50.00 and outstanding -R$ 50.00
    And the 2026-04 statement of card "Purple" shows "+ R$ 120.00 planned"
    And the 2026-04 statement of card "Purple" is "open"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 70.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-09 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 930.00
