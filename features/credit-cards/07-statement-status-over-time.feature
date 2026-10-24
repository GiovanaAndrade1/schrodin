Feature: Derived statement status
  open · closed · paid · overdue · rolled over · in credit · empty. "Partially paid" is a detail of closed/overdue.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-5 @edge
  Scenario Outline: The status changes as days pass, with no payment
    When the day turns to <day>
    Then the 2026-04 statement of card "Purple" is "<status>"

    Examples:
      | day        | status  | case                        |
      | 2026-04-02 | open    | day before the closing date |
      | 2026-04-03 | closed  | closing day                 |
      | 2026-04-10 | closed  | due day                     |
      | 2026-04-11 | overdue | day after the due date      |

  @FAT-5 @FAT-7
  Scenario: A closed statement paid in full becomes paid and does not go overdue
    Given today is 2026-04-08
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08
    Then the 2026-04 statement of card "Purple" is "paid"
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "paid"
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-5 @FAT-8
  Scenario: A statement paid before closing stays open until the closing date
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" is "open"
    When the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" is "paid"

  @FAT-5 @FAT-8
  Scenario: A purchase after an early payment reopens the outstanding amount
    Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    When the day turns to 2026-04-02
    And I add the purchase "Pharmacy" of R$ 45.00 to card "Purple" on 2026-04-02
    And the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" has total R$ 345.00 and outstanding R$ 45.00
    And the 2026-04 statement of card "Purple" is "closed"

  @FAT-5 @FAT-7
  Scenario: A partial payment shows "partially paid" within closed and then within overdue
    Given today is 2026-04-05
    When I pay R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05
    Then the 2026-04 statement of card "Purple" is "closed"
    And the 2026-04 statement of card "Purple" appears as "partially paid"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 200.00
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the 2026-04 statement of card "Purple" appears as "partially paid"

  @FAT-5 @TRF-2
  Scenario: Deleting the payment of a past-due statement turns it back to overdue
    Given today is 2026-04-12
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    And the 2026-04 statement of card "Purple" is "paid"
    When I delete the payment of the 2026-04 statement of card "Purple"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" is "overdue"
    And I see the question "Did you pay?" for the 2026-04 statement of card "Purple"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @FAT-5 @STA-9 @FAT-12
  Scenario: Unconfirming the payment restores the outstanding amount
    Given today is 2026-04-08
    And the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    When I unconfirm the payment of the 2026-04 statement of card "Purple"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-04 statement of card "Purple" is "closed"
    And the actual balance of account "Nubank" is R$ 1,000.00
