Feature: Card purchase and refund confirmed or planned by date

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @STA-6 @edge
  Scenario Outline: Purchase status by date
    When I add the purchase "Item" of R$ 100.00 to card "Purple" on <date>
    Then the purchase "Item" is "<status>"
    And the available limit of card "Purple" is <available>

    Examples:
      | date       | status    | available   |
      | 2026-03-14 | confirmed | R$ 4,900.00 |
      | 2026-03-15 | confirmed | R$ 4,900.00 |
      | 2026-03-16 | planned   | R$ 5,000.00 |

  @STA-6 @PAR-6
  Scenario: Installments of a confirmed purchase are all confirmed, including future ones
    When I add the purchase "TV" of R$ 3,000.00 to card "Purple" on 2026-03-10 in 10 installments
    Then all installments of the purchase "TV" are "confirmed"
    And installment 10 of the purchase "TV" is in the 2027-01 statement of card "Purple"

  @STA-6 @STA-9 @error
  Scenario Outline: A past card purchase and refund cannot be unconfirmed
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 50.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    When I unconfirm <entry>
    Then the operation is blocked with the message "<message>"

    Examples:
      | entry                   | message                                              |
      | the purchase "Sneakers" | A card purchase with a past date is always confirmed |
      | the refund "Sneakers"   | A card refund with a past date is always confirmed   |

  @STA-6 @STA-8 @LIM-3
  Scenario: Moving a confirmed purchase to a future date makes it planned and frees up the limit
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I edit the purchase "Sneakers" to date 2026-03-20
    Then I see the warning "The entry went back to planned because the date is in the future"
    And the purchase "Sneakers" is "planned"
    And the available limit of card "Purple" is R$ 5,000.00
    And the purchase "Sneakers" is in the 2026-04 statement of card "Purple"

  @STA-6 @STA-8 @error
  Scenario: A future purchase cannot be marked as confirmed
    When I add the purchase "Concert" of R$ 150.00 to card "Purple" on 2026-03-20 as confirmed
    Then the operation is blocked with the message "A confirmed entry can't have a future date"
