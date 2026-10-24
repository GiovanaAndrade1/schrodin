Feature: Today's projected balance
  As a user
  I want to see today how much I really have after what is pending
  In order not to spend money that is already spoken for

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 100.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01

  @PRJ-1 @PRJ-2 @STA-4 @FAT-6 @DIA-5 @TRF-7
  Scenario: Today's full formula
    Given the daily amount changes to R$ 50.00 from 2026-03-15
    And the expense "Coffee" of R$ 20.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Coffee" is daily spending
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-12, planned
    And the income "Freelance" of R$ 300.00 in account "Nubank" on 2026-03-15, planned
    And the transfer "Save" of R$ 200.00 from account "Nubank" to account "Reserve" on 2026-03-14, planned
    And the purchase "Sneakers" of R$ 400.00 on card "Purple" on 2026-02-20
    Then the actual balance of account "Nubank" is R$ 1,980.00
    And the 2026-03 statement of card "Purple" is "overdue"
    And the daily reserve on 2026-03-15 is R$ 30.00
    And the consolidated projected balance on 2026-03-15 is R$ 1,570.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 1,470.00
    And the projected balance of account "Wallet" on 2026-03-15 is R$ 100.00
    And the projected balance of account "Reserve" on 2026-03-15 is R$ 5,200.00

  @PRJ-2 @FAT-5 @FAT-6 @edge
  Scenario: A statement due today leaves today
    Given today is 2026-04-10
    And the purchase "Groceries" of R$ 300.00 on card "Purple" on 2026-03-20
    Then the 2026-04 statement of card "Purple" is "closed"
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,700.00

  @PRJ-2 @FAT-5 @FAT-6 @edge
  Scenario: A statement that was due yesterday with no answer starts counting today
    Given today is 2026-04-10
    And the purchase "Groceries" of R$ 300.00 on card "Purple" on 2026-03-20
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,700.00

  @PRJ-2 @FAT-4 @FAT-6
  Scenario: A partially paid overdue statement counts today only for the remainder
    Given the purchase "Sneakers" of R$ 400.00 on card "Purple" on 2026-02-20
    And the payment of R$ 150.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-09, confirmed
    Then the 2026-03 statement of card "Purple" has total R$ 400.00 and outstanding R$ 250.00
    And the actual balance of account "Nubank" is R$ 1,850.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 1,600.00

  @PRJ-2 @FAT-9 @FAT-6
  Scenario: "I didn't pay" removes today's outflow and moves the remainder to the next statement's due date
    Given the purchase "Sneakers" of R$ 400.00 on card "Purple" on 2026-02-20
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-03-10
    Then the projected balance of account "Nubank" on 2026-03-15 is R$ 1,600.00
    When I answer "I didn't pay" for the 2026-03 statement of card "Purple"
    Then the 2026-03 statement of card "Purple" is "rolled over"
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 2,000.00
    And the projected balance of account "Nubank" on 2026-04-09 is R$ 2,000.00
    And the 2026-04 statement of card "Purple" has total R$ 500.00 and outstanding R$ 500.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,500.00

  @PRJ-2 @FAT-8 @STA-4
  Scenario: An overdue planned statement payment counts today and replaces the derived outflow
    Given the purchase "Groceries" of R$ 800.00 on card "Purple" on 2026-03-05
    And the transfer "Pay Purple" of R$ 800.00 from account "Nubank" to card "Purple" on 2026-03-12, planned, linked to the 2026-04 statement
    Then the transfer "Pay Purple" is "overdue"
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 1,200.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,200.00

  @INV-9 @PRJ-1 @CON-6
  Scenario: With no planned entries, no outstanding statement and zero daily budget, today = consolidated actual balance
    Given the account "Itaú" of kind "checking" with opening balance R$ 1,234.56 on 2026-03-01
    And the purchase "Book" of R$ 90.00 on card "Purple" on 2026-03-05
    And the payment of R$ 90.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    Then the actual balance of account "Nubank" is R$ 1,910.00
    And the 2026-04 statement of card "Purple" has total R$ 90.00 and outstanding R$ 0.00
    And the consolidated projected balance on 2026-03-15 is R$ 3,244.56
    And the consolidated projected balance on 2026-03-15 equals the consolidated actual balance
