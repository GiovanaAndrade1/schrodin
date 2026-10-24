Feature: Manually moving a purchase to another statement
  One cycle per action, only between statements that are not closed (closing date > today).

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Hotel" of R$ 500.00 on card "Purple" on 2026-03-12

  @FAT-2 @FAT-6 @LIM-1
  Scenario: Moving a purchase to the next statement pins the purchase
    When I move the purchase "Hotel" to the next statement
    Then the purchase "Hotel" is in the 2026-05 statement of card "Purple"
    And the purchase "Hotel" is pinned
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 500.00
    And the available limit of card "Purple" is R$ 4,500.00

  @FAT-2
  Scenario: Moving again advances one more cycle
    Given I moved the purchase "Hotel" to the next statement
    When I move the purchase "Hotel" to the next statement
    Then the purchase "Hotel" is in the 2026-06 statement of card "Purple"
    And the purchase "Hotel" is pinned

  @FAT-2 @error
  Scenario: Moving to a previous statement that is already closed is blocked
    When I move the purchase "Hotel" to the previous statement
    Then the operation is blocked with the message "You can only move between statements that haven't closed yet"
    And the purchase "Hotel" is in the 2026-04 statement of card "Purple"

  @FAT-2 @FAT-5 @error
  Scenario: A purchase of a closed statement cannot be moved
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    When I move the purchase "Dinner" to the next statement
    Then the operation is blocked with the message "You can only move between statements that haven't closed yet"
    And the purchase "Dinner" is in the 2026-03 statement of card "Purple"

  @FAT-2 @FAT-5 @error @edge
  Scenario: On the closing day the statement already counts as closed for the lock
    Given today is 2026-04-03
    When I move the purchase "Hotel" to the next statement
    Then the operation is blocked with the message "You can only move between statements that haven't closed yet"

  @FAT-2
  Scenario: Moving back to the statement of the date's cycle removes the pin
    Given I moved the purchase "Hotel" to the next statement
    When I move the purchase "Hotel" to the previous statement
    Then the purchase "Hotel" is in the 2026-04 statement of card "Purple"
    And the purchase "Hotel" is not pinned

  @FAT-2 @FAT-1
  Scenario: Changing the date of a pinned purchase removes the pin and reallocates it
    Given I moved the purchase "Hotel" to the next statement
    When I edit the purchase "Hotel" to date 2026-03-13
    Then I see the warning "The purchase is no longer pinned and goes back to the statement of the new date's cycle"
    And the purchase "Hotel" is in the 2026-04 statement of card "Purple"
    And the purchase "Hotel" is not pinned
