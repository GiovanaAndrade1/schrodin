Feature: Credit from overpayment or a refund larger than the statement
  A closed statement passes the credit to the next one right away and ends up with outstanding 0. An open statement keeps the negative amount until it closes.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-10 @FAT-4 @LIM-1
  Scenario: Overpaying a closed statement generates credit on the next one
    Given today is 2026-04-05
    When I pay R$ 350.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05
    Then the 2026-04 statement of card "Purple" is "paid"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 50.00
    And the 2026-05 statement of card "Purple" has total -R$ 50.00 and outstanding -R$ 50.00
    And the total debt of card "Purple" is -R$ 50.00
    And the available limit of card "Purple" is R$ 5,050.00
    And the limit of card "Purple" is shown as "R$ 5,000.00 + R$ 50.00 of credit"
    And the actual balance of account "Nubank" is R$ 650.00

  @FAT-10 @FAT-6
  Scenario: Credit offsets the purchases of the next statement
    Given today is 2026-04-05
    And the payment of R$ 350.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05, confirmed
    When I add the purchase "Book" of R$ 100.00 to card "Purple" on 2026-04-05
    Then the 2026-05 statement of card "Purple" has total R$ 50.00 and outstanding R$ 50.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 50.00 on 2026-05-10
    And the available limit of card "Purple" is R$ 4,950.00

  @FAT-10 @FAT-5 @edge
  Scenario: Credit larger than the next statement is passed on at closing
    Given today is 2026-04-05
    And the payment of R$ 800.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-05, confirmed
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-04-05
    Then the 2026-05 statement of card "Purple" has carried-over credit R$ 500.00
    And the 2026-05 statement of card "Purple" has total -R$ 400.00 and outstanding -R$ 400.00
    When the day turns to 2026-05-03
    Then the 2026-05 statement of card "Purple" has outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" is "in credit"
    And the 2026-06 statement of card "Purple" has carried-over credit R$ 400.00
    And the actual balance of account "Nubank" is R$ 200.00

  @FAT-10 @FAT-8 @edge
  Scenario: An open statement is overpaid early, with a purchase afterwards
    Given today is 2026-03-15
    And the payment of R$ 400.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding -R$ 100.00
    And the 2026-04 statement of card "Purple" is "open"
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 0.00
    When I add the purchase "Coffee" of R$ 50.00 to card "Purple" on 2026-03-15
    Then the 2026-04 statement of card "Purple" has total R$ 350.00 and outstanding -R$ 50.00
    When the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" is "paid"
    And the 2026-04 statement of card "Purple" has outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 50.00

  @FAT-10 @FAT-6 @FAT-8
  Scenario: The negative amount of an open statement already offsets the derived outflow of the next one
    Given today is 2026-03-15
    And the daily amount is R$ 0.00 since 2026-01-01
    And the payment of R$ 400.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    And the purchase "Book" of R$ 150.00 on card "Purple" on 2026-04-05
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding -R$ 100.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 50.00 on 2026-05-10
    And the actual balance of account "Nubank" is R$ 600.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 550.00

  @FAT-10 @EST-2 @EST-4 @LIM-1 @FAT-6 @FAT-5
  Scenario: An unlinked refund larger than the statement generates credit
    Given today is 2026-03-15
    When I add the refund "Reimbursement" of R$ 400.00 to card "Purple" on 2026-03-15
    Then the 2026-04 statement of card "Purple" has total -R$ 100.00 and outstanding -R$ 100.00
    And the total debt of card "Purple" is -R$ 100.00
    And the available limit of card "Purple" is R$ 5,100.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    When the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" is "in credit"
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 100.00
