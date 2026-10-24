Feature: Statement derived outflow in the projection
  Derived outflow = max(outstanding + planned purchases − planned refunds + daily reserve of the cycle − planned payments, 0), in the payment account, on the due date. Overdue counts today.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-6 @PRJ-6
  Scenario: The derived outflow falls on the due date, with no saved entry
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 300.00 on 2026-04-10
    And there is no saved entry for that outflow
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-09 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @FAT-6 @FAT-8
  Scenario: A partial planned payment replaces part of the derived outflow
    Given the payment of R$ 200.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 100.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-08 is R$ 800.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @FAT-6 @FAT-8 @edge
  Scenario: A planned payment equal to the outstanding amount zeroes the derived outflow
    Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @FAT-6 @FAT-8 @edge
  Scenario: The excess of the planned payment offsets the derived outflow of the next statement
    Given the purchase "Book" of R$ 150.00 on card "Purple" on 2026-04-05
    And the payment of R$ 400.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 50.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-04-08 is R$ 600.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 550.00

  @FAT-6 @FAT-8
  Scenario: An early confirmed payment reduces the actual balance and the derived outflow
    Given the payment of R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    Then the actual balance of account "Nubank" is R$ 900.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 200.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @FAT-6 @PRJ-2 @edge
  Scenario: A statement due today comes out of today's balance
    When the day turns to 2026-04-10
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @FAT-6 @FAT-9 @STA-4 @PRJ-2
  Scenario: An overdue statement counts today, until the user answers
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 300.00 on 2026-04-11
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 700.00
    When the day turns to 2026-04-20
    Then the projected balance of account "Nubank" on 2026-04-20 is R$ 700.00

  @FAT-6 @FAT-9 @STA-4 @edge
  Scenario: An overdue planned payment and an overdue statement are not counted twice
    Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned
    When the day turns to 2026-04-11
    Then the payment of the 2026-04 statement of card "Purple" is "overdue"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 700.00
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-6 @STA-6
  Scenario: Planned purchases and refunds go into the derived outflow
    Given the purchase "Dinner" of R$ 80.00 on card "Purple" on 2026-03-20
    And the refund "Sneakers" of R$ 30.00 on card "Purple" on 2026-03-25 linked to the purchase "Sneakers"
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 350.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 650.00

  @FAT-6 @FAT-11 @FAT-5 @edge
  Scenario: An open statement with only planned purchases stays open and generates a derived outflow
    Given the purchase "Concert" of R$ 120.00 on card "Purple" on 2026-04-05
    Then the 2026-05 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" is "open"
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 120.00 on 2026-05-10

  @FAT-6 @DIA-10 @DIA-5
  Scenario: A daily reserve sourced from the card goes into the derived outflow of the cycle
    Given the daily amount is R$ 50.00 since 2026-01-01
    And the daily budget source is card "Purple"
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 1,250.00 on 2026-04-10
    And the projected balance of account "Nubank" on 2026-04-09 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-10 is -R$ 250.00

  @FAT-6 @PAR-1 @PRJ-7
  Scenario: An installment purchase generates one derived outflow per due date
    Given the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    Then the projected balance of account "Nubank" on 2026-04-10 is R$ 400.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 100.00
    And the projected balance of account "Nubank" on 2026-06-10 is -R$ 200.00
    And the projected balance of account "Nubank" on 2027-01-10 is -R$ 2,300.00
    And the first negative day is 2026-06-10
    And the lowest future balance is -R$ 2,300.00 on 2027-01-10

  @FAT-6 @CAR-3
  Scenario: Switching the payment account moves the derived outflow
    Given the account "Wallet" of kind "cash" with opening balance R$ 500.00 on 2026-01-01
    When I change the default payment account of card "Purple" to "Wallet"
    Then the projected balance of account "Nubank" on 2026-04-10 is R$ 1,000.00
    And the projected balance of account "Wallet" on 2026-04-10 is R$ 200.00
