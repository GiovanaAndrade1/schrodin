Feature: Card refund

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @EST-1 @EST-2 @LIM-1
  Scenario: A full linked refund zeroes the purchase in the statement and gives back the limit
    When I add the refund "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    Then the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the actual balance of account "Nubank" is R$ 1,000.00

  @EST-1 @EST-2
  Scenario: A partial refund reduces the statement
    When I add the refund "Sneakers" of R$ 100.00 to card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    Then the 2026-04 statement of card "Purple" has total R$ 200.00 and outstanding R$ 200.00
    And the available limit of card "Purple" is R$ 4,800.00

  @EST-1 @FAT-1
  Scenario: A refund falls in the statement of its own date's cycle, not the purchase's
    Given today is 2026-04-05
    When I add the refund "Sneakers" of R$ 100.00 to card "Purple" on 2026-04-05 linked to the purchase "Sneakers"
    Then the refund "Sneakers" is in the 2026-05 statement of card "Purple"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the available limit of card "Purple" is R$ 4,800.00

  @EST-1
  Scenario: A linked refund is created with the purchase's tags, which can be changed
    Given the purchase "Sneakers" has the tags "clothing"
    When I open the refund form linked to the purchase "Sneakers"
    Then the form tags are "clothing"
    When I switch the tags to "gift" and add the refund "Sneakers" of R$ 50.00 to card "Purple" on 2026-03-15
    Then the refund "Sneakers" has the tags "gift"
    And the purchase "Sneakers" has the tags "clothing"

  @EST-4 @edge @error
  Scenario Outline: Linked refund cap
    Given the purchase "Sneakers" already has R$ <previous> in linked refunds
    When I add the refund "Sneakers" of R$ <new> to card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    Then the result is "<result>"

    Examples:
      | previous | new    | result                                     |
      | 0.00     | 300.00 | accepted                                   |
      | 0.00     | 300.01 | blocked: The refund can't exceed R$ 300.00 |
      | 100.00   | 200.00 | accepted                                   |
      | 100.00   | 200.01 | blocked: The refund can't exceed R$ 200.00 |
      | 300.00   | 0.01   | blocked: The refund can't exceed R$ 0.00   |

  @EST-4 @edge
  Scenario: When editing a refund, the cap does not count the refund itself
    Given the refund "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    When I edit the refund "Sneakers" to R$ 300.00
    Then the refund "Sneakers" has amount R$ 300.00
    When I edit the refund "Sneakers" to R$ 300.01
    Then the operation is blocked with the message "The refund can't exceed R$ 300.00"

  @EST-4 @LAN-8 @error
  Scenario Outline: A purchase cannot become smaller than the sum of its refunds
    Given the refund "Sneakers" of R$ 200.00 on card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    When I edit the purchase "Sneakers" to <amount>
    Then the result is "<result>"

    Examples:
      | amount    | result                                                |
      | R$ 200.00 | accepted                                              |
      | R$ 199.99 | blocked: The purchase has R$ 200.00 in linked refunds |

  @EST-2 @EST-4 @FAT-10 @LIM-1
  Scenario: An unlinked refund has no cap and leaves the open statement negative
    When I add the refund "Store Adjustment" of R$ 1,000.00 to card "Purple" on 2026-03-15, unlinked
    Then the 2026-04 statement of card "Purple" has total -R$ 700.00 and outstanding -R$ 700.00
    And the available limit of card "Purple" is R$ 5,700.00
    And the card "Purple" screen shows "limit + credit"

  @EST-1 @error
  Scenario Outline: Link only to a confirmed purchase on the same card dated up to the refund date
    Given the purchase "Ticket" of R$ 800.00 on card "Purple" on 2026-03-20
    And the purchase "Jacket" of R$ 250.00 on card "Purple" on 2026-03-14
    When I add the refund "Test" of R$ 50.00 to card "<card>" on <date> linked to the purchase "<purchase>"
    Then the operation is blocked with the message "<message>"

    Examples:
      | card   | date       | purchase | message                                       |
      | Black  | 2026-03-15 | Sneakers | The linked purchase must be on the same card  |
      | Purple | 2026-03-15 | Ticket   | You can only link to a confirmed purchase     |
      | Purple | 2026-03-13 | Jacket   | The linked purchase can't be after the refund |

  @EST-1 @STA-6 @LIM-3
  Scenario: A refund with a future date is planned and confirms itself on the date
    When I add the refund "Sneakers" of R$ 100.00 to card "Purple" on 2026-03-16 linked to the purchase "Sneakers"
    Then the refund "Sneakers" is "planned"
    And the available limit of card "Purple" is R$ 4,700.00
    When the day turns to 2026-03-16
    Then the refund "Sneakers" is "confirmed"
    And the available limit of card "Purple" is R$ 4,800.00
    And I see the warning "The refund 'Sneakers' was confirmed; delete it if it didn't happen"

  @EST-3 @IND-1 @IND-2 @IND-3
  Scenario Outline: A refund reduces Outflows or Daily spending according to the linked purchase, never an Inflow
    Given the purchase "Snack" of R$ 50.00 on card "Purple" on 2026-03-12, as daily spending
    When I add the refund "Payback" of R$ 20.00 to card "Purple" on 2026-03-15 <link>
    Then the realized Inflows for 2026-03 are R$ 0.00
    And the realized Outflows for 2026-03 are <outflows>
    And the realized Daily spending for 2026-03 is <daily spending>

    Examples:
      | link                              | outflows  | daily spending |
      | linked to the purchase "Sneakers" | R$ 280.00 | R$ 50.00       |
      | linked to the purchase "Snack"    | R$ 300.00 | R$ 30.00       |
      | unlinked                          | R$ 280.00 | R$ 50.00       |

  @EST-3 @IND-2 @IND-3 @edge
  Scenario: The current daily spending flag of the linked purchase applies
    Given the purchase "Snack" of R$ 50.00 on card "Purple" on 2026-03-12, as daily spending
    And the refund "Payback" of R$ 20.00 on card "Purple" on 2026-03-15 linked to the purchase "Snack"
    When I uncheck daily spending on the purchase "Snack"
    Then the realized Daily spending for 2026-03 is R$ 0.00
    And the realized Outflows for 2026-03 are R$ 330.00

  @EST-3 @IND-2 @edge
  Scenario: A refund counts in the month of its date and can make Outflows negative
    Given today is 2026-04-15
    When I add the refund "Sneakers" of R$ 100.00 to card "Purple" on 2026-04-10 linked to the purchase "Sneakers"
    Then the realized Outflows for 2026-03 are R$ 300.00
    And the realized Outflows for 2026-04 are -R$ 100.00
    And the refund "Sneakers" is in the 2026-05 statement of card "Purple"
