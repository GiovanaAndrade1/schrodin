Feature: Per-account and consolidated projection
  As a user
  I want to see the projection of each account and the sum of the spending money
  In order for internal transfers not to look like spending

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01

  @PRJ-5 @CON-5 @TRF-7 @INV-2 @CON-6
  Scenario Outline: A planned transfer between accounts in the consolidated balance
    Given the transfer "Move" of R$ 500.00 from account "<source>" to account "<destination>" on 2026-03-20, planned
    Then the consolidated projected balance on 2026-03-19 is R$ 1,200.00
    And the projected balance of account "Nubank" on 2026-03-20 is <Nubank>
    And the projected balance of account "Wallet" on 2026-03-20 is <Wallet>
    And the projected balance of account "Reserve" on 2026-03-20 is <Reserve>
    And the consolidated projected balance on 2026-03-20 is <consolidated>

    Examples:
      | source  | destination | Nubank      | Wallet     | Reserve     | consolidated |
      | Nubank  | Wallet      | R$ 500.00   | R$ 700.00  | R$ 5,000.00 | R$ 1,200.00  |
      | Wallet  | Nubank      | R$ 1,500.00 | -R$ 300.00 | R$ 5,000.00 | R$ 1,200.00  |
      | Nubank  | Reserve     | R$ 500.00   | R$ 200.00  | R$ 5,500.00 | R$ 700.00    |
      | Reserve | Nubank      | R$ 1,500.00 | R$ 200.00  | R$ 4,500.00 | R$ 1,700.00  |

  @PRJ-5 @CON-6 @IND-12
  Scenario: Movement in a saving account does not touch the consolidated balance
    Given the income "Yield" of R$ 40.00 in account "Reserve" on 2026-03-31, planned
    And the expense "Fee" of R$ 15.00 in account "Reserve" on 2026-04-01, planned
    Then the projected balance of account "Reserve" on 2026-04-01 is R$ 5,025.00
    And the consolidated projected balance on 2026-04-01 is R$ 1,200.00

  @PRJ-5 @TRF-7 @FAT-6 @FAT-8
  Scenario Outline: A planned statement payment replaces the derived outflow
    Given the purchase "Groceries" of R$ 800.00 on card "Purple" on 2026-03-05
    And confirmed payments totaling <confirmed> of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15
    And planned payments totaling <planned> of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08
    Then the projected balance of account "Nubank" on 2026-04-08 is <Nubank 04-08>
    And the derived outflow of the 2026-04 statement of card "Purple" is <derived> on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 200.00
    And the consolidated projected balance on 2026-04-10 is R$ 400.00

    Examples:
      | confirmed | planned   | Nubank 04-08 | derived   |
      | R$ 0.00   | R$ 0.00   | R$ 1,000.00  | R$ 800.00 |
      | R$ 0.00   | R$ 500.00 | R$ 500.00    | R$ 300.00 |
      | R$ 0.00   | R$ 800.00 | R$ 200.00    | R$ 0.00   |
      | R$ 300.00 | R$ 0.00   | R$ 700.00    | R$ 500.00 |
      | R$ 300.00 | R$ 500.00 | R$ 200.00    | R$ 0.00   |

  @FAT-6 @FAT-8 @FAT-10 @edge
  Scenario: A planned payment larger than the statement becomes projected credit on the next one
    Given the purchase "Groceries" of R$ 800.00 on card "Purple" on 2026-03-05
    And the purchase "Book" of R$ 300.00 on card "Purple" on 2026-04-05
    And the transfer "Pay Purple" of R$ 1,000.00 from account "Nubank" to card "Purple" on 2026-04-08, planned, linked to the 2026-04 statement
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 100.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-04-08 is R$ 0.00
    And the projected balance of account "Nubank" on 2026-05-10 is -R$ 100.00

  @FAT-8 @FAT-6 @edge
  Scenario: The excess of a planned payment goes in order through the following statements until it runs out
    Given the purchase "Groceries" of R$ 800.00 on card "Purple" on 2026-03-05
    And the purchase "Book" of R$ 300.00 on card "Purple" on 2026-04-05
    And the purchase "Course" of R$ 500.00 on card "Purple" on 2026-05-05
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-06-05
    And the transfer "Pay Purple" of R$ 1,500.00 from account "Nubank" to card "Purple" on 2026-04-08, planned, linked to the 2026-04 statement
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 0.00 on 2026-05-10
    And the derived outflow of the 2026-06 statement of card "Purple" is R$ 100.00 on 2026-06-10
    And the derived outflow of the 2026-07 statement of card "Purple" is R$ 200.00 on 2026-07-10
    And the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-04-07 | R$ 1,000.00 |
      | 2026-04-08 | -R$ 500.00  |
      | 2026-05-10 | -R$ 500.00  |
      | 2026-06-10 | -R$ 600.00  |
      | 2026-07-10 | -R$ 800.00  |

  @FAT-10 @FAT-6 @FAT-8 @LIM-1 @INV-5
  Scenario: A negative amount on the open statement already reduces the derived outflow of the following ones
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-05
    And the payment of R$ 400.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the purchase "Book" of R$ 250.00 on card "Purple" on 2026-04-05
    Then the 2026-04 statement of card "Purple" is "open"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding -R$ 100.00
    And the available limit of card "Purple" is R$ 5,100.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 150.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 600.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 450.00

  @FAT-11 @FAT-6 @edge
  Scenario Outline: A statement with nothing to pay creates no outflow
    Given <situation>
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is <balance>

    Examples:
      | situation                                                                                                                                                                   | balance     |
      | no purchase on card "Purple"                                                                                                                                                | R$ 1,000.00 |
      | the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-05 and the refund "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-06 linked to the purchase "Sneakers" | R$ 1,000.00 |
      | the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-05 and the payment of R$ 400.00 of the 2026-04 statement from account "Nubank" on 2026-03-10               | R$ 600.00   |

  @CAR-3 @PRJ-5 @error
  Scenario: A saving account cannot be the card's payment account
    When I change the default payment account of card "Purple" to "Reserve"
    Then the operation is blocked with the message "The payment account must be a spending account"
    And the default payment account of card "Purple" is "Nubank"
