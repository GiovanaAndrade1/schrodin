Feature: Purchase and refund status on the card

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @STA-6 @LIM-1
  Scenario: A purchase with a past or today's date is confirmed and uses limit
    When I add the expense "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-15
    Then the purchase "Sneakers" is "confirmed"
    And the available limit of card "Purple" is R$ 4,700.00

  @STA-6 @LIM-3 @FAT-4
  Scenario: A future purchase is planned, appears separately in the statement and does not use limit
    When I add the expense "Ticket" of R$ 800.00 to card "Purple" on 2026-03-20
    Then the purchase "Ticket" is "planned"
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" shows "+ R$ 800.00 planned"
    And the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Purple" after planned entries is R$ 4,200.00

  @STA-6 @error
  Scenario: A purchase with a past date cannot be added as planned
    When I add the expense "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-10 as planned
    Then the operation is blocked with the message "A card purchase with a past date is always confirmed"

  @STA-6 @STA-9 @error
  Scenario Outline: A confirmed purchase or refund on the card cannot be unconfirmed
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    When I unconfirm <entry>
    Then the operation is blocked with the message "<message>"

    Examples:
      | entry                   | message                                              |
      | the purchase "Sneakers" | A card purchase with a past date is always confirmed |
      | the refund "Sneakers"   | A card refund with a past date is always confirmed   |

  @STA-6 @LIM-1 @GER-3
  Scenario: A planned card purchase confirms itself when the date arrives, with a warning
    Given the purchase "Ticket" of R$ 800.00 on card "Purple" on 2026-03-16
    And the purchase "Ticket" is "planned"
    When the day turns to 2026-03-16
    Then the purchase "Ticket" is "confirmed"
    And the available limit of card "Purple" is R$ 4,200.00
    And I see the warning "The purchase 'Ticket' was confirmed; delete it if it didn't happen"

  @STA-6 @STA-8
  Scenario: A confirmed purchase edited to a future date goes back to planned and frees limit
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-15
    When I edit the purchase "Sneakers" to date 2026-03-25
    Then the purchase "Sneakers" is "planned"
    And the available limit of card "Purple" is R$ 5,000.00
