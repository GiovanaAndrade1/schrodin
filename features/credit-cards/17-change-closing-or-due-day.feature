Feature: Changing the card's closing or due day
  Applies from the current open statement onward. If the new day has not come yet this month, the open statement closes on it; otherwise, in the following month. Closed statements do not change. Pinned purchases stay on the same statement.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-03-05
    And the purchase "Groceries" of R$ 150.00 on card "Purple" on 2026-03-12
    And the purchase "Concert" of R$ 80.00 on card "Purple" on 2026-04-05
    And the purchase "Bar" of R$ 60.00 on card "Purple" on 2026-04-12

  @CAR-5 @FAT-1 @FAT-3 @FAT-4
  Scenario: A later closing day reallocates the open statement and the future ones
    When I change the closing day of card "Purple" to 10 and the due day to 17
    Then I see the new dates before confirming: closing on 2026-04-10 and due on 2026-04-17
    And the 2026-04 statement of card "Purple" closes on 2026-04-10 and is due on 2026-04-17
    And the purchase "Concert" is in the 2026-04 statement of card "Purple"
    And the 2026-04 statement of card "Purple" has total R$ 250.00 and outstanding R$ 250.00
    And the 2026-04 statement of card "Purple" shows "+ R$ 80.00 planned"
    And the purchase "Bar" is in the 2026-05 statement of card "Purple"
    And the 2026-05 statement of card "Purple" closes on 2026-05-10 and is due on 2026-05-17
    And the 2026-05 statement of card "Purple" shows "+ R$ 60.00 planned"

  @CAR-5
  Scenario: An already closed statement does not change
    When I change the closing day of card "Purple" to 10 and the due day to 17
    Then the 2026-03 statement of card "Purple" closes on 2026-03-03 and is due on 2026-03-10
    And the purchase "Dinner" is in the 2026-03 statement of card "Purple"
    And the 2026-03 statement of card "Purple" has total R$ 200.00 and outstanding R$ 200.00

  @CAR-5 @FAT-1
  Scenario: An earlier closing day shortens the open statement
    When I change the closing day of card "Purple" to 20 and the due day to 10
    Then the 2026-04 statement of card "Purple" closes on 2026-03-20 and is due on 2026-04-10
    And the 2026-04 statement of card "Purple" has total R$ 250.00 and outstanding R$ 250.00
    And the 2026-05 statement of card "Purple" closes on 2026-04-20 and is due on 2026-05-10
    And the purchase "Concert" is in the 2026-05 statement of card "Purple"
    And the purchase "Bar" is in the 2026-05 statement of card "Purple"
    And the 2026-05 statement of card "Purple" shows "+ R$ 140.00 planned"

  @CAR-5 @CAR-2 @edge
  Scenario Outline: New closing date of the current open statement relative to today
    When I change the closing day of card "Purple" to <closing day> and the due day to <due day>
    Then the current open statement of card "Purple" closes on <closes> and is due on <due>

    Examples:
      | closing day | due day | closes     | due        | case                                           |
      | 16          | 10      | 2026-03-16 | 2026-04-10 | tomorrow: not reached yet                      |
      | 20          | 10      | 2026-03-20 | 2026-04-10 | has not arrived yet this month                 |
      | 31          | 10      | 2026-03-31 | 2026-04-10 | last day of the month                          |
      | 15          | 22      | 2026-04-15 | 2026-04-22 | today: already reached, goes to the next month |
      | 12          | 20      | 2026-04-12 | 2026-04-20 | already passed this month                      |
      | 2           | 10      | 2026-04-02 | 2026-04-10 | before the old closing date                    |
      | 3           | 10      | 2026-04-03 | 2026-04-10 | no change                                      |

  @CAR-5 @FAT-6
  Scenario: Changing only the due day moves the derived outflow
    Given the daily amount is R$ 0.00 since 2026-01-01
    When I change the due day of card "Purple" to 20
    Then the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-20
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 250.00 on 2026-04-20
    And the 2026-03 statement of card "Purple" closes on 2026-03-03 and is due on 2026-03-10

  @CAR-5 @FAT-5
  Scenario: A closed statement not yet due keeps the old due date
    Given today is 2026-03-05
    And the 2026-03 statement of card "Purple" is "closed"
    When I change the due day of card "Purple" to 15
    Then the 2026-03 statement of card "Purple" closes on 2026-03-03 and is due on 2026-03-10
    And the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-15

  @CAR-5 @FAT-0 @FAT-3 @edge
  Scenario: A new due day before the closing day changes the label, not the identity
    Given I call the 2026-03 statement of card "Purple" "statement A"
    And I call the 2026-04 statement of card "Purple" "statement B"
    And I call the 2026-05 statement of card "Purple" "statement C"
    When I change the due day of card "Purple" to 1
    Then "statement B" closes on 2026-04-03, is due on 2026-05-01 and has label 2026-05
    And the purchase "Groceries" is in "statement B"
    And "statement C" closes on 2026-05-03, is due on 2026-06-01 and has label 2026-06
    And the purchase "Bar" is in "statement C"
    And "statement A" closes on 2026-03-03, is due on 2026-03-10 and has label 2026-03
    And the purchase "Dinner" is in "statement A"

  @CAR-5 @FAT-0 @edge
  Scenario: Repeated labels after the change show due date and closing date
    Given the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And I call the 2026-03 statement of card "Black" "statement A"
    And I call the 2026-04 statement of card "Black" "statement B"
    When I change the due day of card "Black" to 30
    Then "statement A" closes on 2026-02-28 and is due on 2026-03-05
    And "statement B" closes on 2026-03-28 and is due on 2026-03-30
    And the two statements are distinct
    And the labels are "due 03-05 · closed 02-28" and "due 03-30 · closed 03-28"

  @CAR-5 @FAT-2
  Scenario: A pinned purchase stays on the same statement
    Given I moved the purchase "Groceries" to the next statement
    When I change the closing day of card "Purple" to 10 and the due day to 17
    Then the purchase "Groceries" is in the 2026-05 statement of card "Purple"
    And the purchase "Groceries" is pinned
    And the 2026-04 statement of card "Purple" has total R$ 100.00 and outstanding R$ 100.00
    And the 2026-05 statement of card "Purple" has total R$ 150.00 and outstanding R$ 150.00

  @CAR-5 @PAR-1
  Scenario: Future installments stay one per consecutive statement
    Given the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I change the closing day of card "Purple" to 20 and the due day to 10
    Then the installments of the purchase "TV" are:
      | k  | amount    | statement |
      | 1  | R$ 300.00 | 2026-04   |
      | 2  | R$ 300.00 | 2026-05   |
      | 10 | R$ 300.00 | 2027-01   |

  @CAR-5 @CAR-1 @error
  Scenario: A new day outside 1 to 31 is blocked
    When I change the closing day of card "Purple" to 32 and the due day to 10
    Then the operation is blocked with the message "Closing day must be between 1 and 31"
    And the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-10
