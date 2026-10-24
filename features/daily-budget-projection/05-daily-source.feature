Feature: Daily budget source
  As a user
  I want to choose whether the daily budget comes out of the account or the card
  In order for the reserve to leave the cash in the right place

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the projection horizon is 12 months

  @DIA-10 @DIA-7
  Scenario: By default the reserve leaves the default account, every day
    Then the daily budget source is account "Nubank"
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 2,950.00
    And the projected balance of account "Nubank" on 2026-03-16 is R$ 2,900.00
    And the projected balance of account "Wallet" on 2026-03-16 is R$ 0.00

  @DIA-10 @DIA-7 @FAT-5 @FAT-6 @PRJ-4
  Scenario: Card source: each day's reserve goes into the cycle's statement and leaves on the due date
    When I set the daily budget source to card "Purple"
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 950.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,500.00 on 2026-05-10
    And the derived outflow of the 2026-06 statement of card "Purple" is R$ 1,550.00 on 2026-06-10
    And the projected balance of account "Nubank" is:
      | date       | balance      |
      | 2026-03-15 | R$ 3,000.00  |
      | 2026-04-09 | R$ 3,000.00  |
      | 2026-04-10 | R$ 2,050.00  |
      | 2026-05-09 | R$ 2,050.00  |
      | 2026-05-10 | R$ 550.00    |
      | 2026-06-10 | -R$ 1,000.00 |

  @DIA-10 @LIM-3
  Scenario: A reserve with a card source does not use limit nor appear as a purchase
    Given the daily budget source is card "Purple"
    Then the available limit of card "Purple" is R$ 5,000.00
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 950.00 on 2026-04-10

  @DIA-10 @DIA-8
  Scenario: Card source with daily spending on the card itself: the statement still has R$ 50.00 per day
    Given the daily budget source is card "Purple"
    And the purchase "Lunch" of R$ 35.00 on card "Purple" on 2026-03-15
    And the purchase "Lunch" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 15.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 950.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 2,050.00

  @DIA-10 @DIA-5
  Scenario: Card source with daily spending in an account: the account pays today, the statement takes only the rest
    Given the daily budget source is card "Purple"
    And the expense "Coffee" of R$ 20.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Coffee" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 30.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 2,980.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 930.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 2,050.00

  @DIA-10 @FAT-1 @FAT-11 @edge
  Scenario: Card source on the closing day: today's reserve goes to the next statement
    Given today is 2026-04-03
    And the daily budget source is card "Purple"
    Then the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-10
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,500.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 3,000.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 1,500.00

  @DIA-10 @FAT-6 @FAT-8
  Scenario: Planned statement payment with the daily reserve inside
    Given the daily budget source is card "Purple"
    And the purchase "Groceries" of R$ 200.00 on card "Purple" on 2026-03-05
    And the transfer "Pay Purple" of R$ 500.00 from account "Nubank" to card "Purple" on 2026-04-08, planned, linked to the 2026-04 statement
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 650.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-08 is R$ 2,500.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,850.00

  @DIA-10 @CAR-4 @GER-5
  Scenario: Archived source card: the daily budget goes back to the default account with a warning
    Given the daily budget source is card "Purple"
    When I archive the card "Purple"
    Then I see the warning "The daily budget source went back to the default account Nubank"
    And the daily budget source is account "Nubank"
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 2,950.00

  @DIA-10 @PRJ-7 @PRJ-3 @edge
  Scenario: The reserve for days within the horizon in a statement due after it appears next to the lowest balance
    Given the daily budget source is card "Purple"
    And the projection horizon is 1 month
    Then the projection runs from 2026-03-15 to 2026-04-15
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 2,050.00
    And the projected balance of account "Nubank" on 2026-04-15 is R$ 2,050.00
    And the lowest future balance is R$ 2,050.00 on 2026-04-10
    And next to the lowest balance I see "R$ 650.00 of daily spending in statements beyond the horizon"

  @DIA-10 @error
  Scenario: A saving account cannot be the daily budget source
    When I set the daily budget source to account "Reserve"
    Then the operation is blocked with the message "The daily budget source must be a spending account or a card"
    And the daily budget source is account "Nubank"

  @DIA-10
  Scenario: The source can be a spending account that is not the default one
    When I set the daily budget source to account "Wallet"
    Then the projected balance of account "Wallet" on 2026-03-15 is -R$ 50.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 3,000.00
    And the consolidated projected balance on 2026-03-15 is R$ 2,950.00

  @DIA-10 @CON-9 @error
  Scenario: Archiving the account that is the explicit daily budget source is blocked
    Given the daily budget source is account "Wallet"
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                  | offered action                 |
      | It is the daily budget source | Change the daily budget source |
    And the daily budget source is account "Wallet"

  @DIA-10 @CON-12 @error
  Scenario: An account that is the explicit daily budget source cannot become saving
    Given the daily budget source is account "Wallet"
    When I change the purpose of account "Wallet" to "saving"
    Then the operation is blocked with the message "The daily budget source must be a spending account. Change the source first"
    And the account "Wallet" has purpose "spending"

  @DIA-10 @CON-10
  Scenario: Source "the default account" follows the change of default account
    Given the daily budget source is the default account
    When I set "Wallet" as the default account
    Then the daily budget source is account "Wallet"
    And the projected balance of account "Wallet" on 2026-03-15 is -R$ 50.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 3,000.00
