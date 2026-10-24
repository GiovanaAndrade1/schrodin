Feature: Statement total and outstanding amount
  Total = carried-over balance + confirmed purchases and installments of the cycle − confirmed refunds of the cycle − carried-over credit. Outstanding = total − confirmed payments + credit withdrawals. Planned entries appear separately.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @FAT-4 @EST-1 @EST-2 @FAT-8
  Scenario: Purchases, refund and early payment on the same statement
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "Groceries" of R$ 120.00 on card "Purple" on 2026-03-12
    And the refund "Groceries" of R$ 50.00 on card "Purple" on 2026-03-14 linked to the purchase "Groceries"
    And the payment of R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    Then the 2026-04 statement of card "Purple" has total R$ 370.00 and outstanding R$ 270.00
    And the actual balance of account "Nubank" is R$ 900.00

  @FAT-4 @STA-6 @LIM-1 @INV-5
  Scenario: Planned purchase and refund appear separately, outside the total
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "Dinner" of R$ 80.00 on card "Purple" on 2026-03-20
    And the refund "Sneakers" of R$ 30.00 on card "Purple" on 2026-03-25 linked to the purchase "Sneakers"
    Then the purchase "Dinner" is "planned"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-04 statement of card "Purple" shows "+ R$ 50.00 planned"
    And the total debt of card "Purple" is R$ 300.00

  @FAT-4 @PAR-1
  Scenario: Installments go one into each statement
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    Then the 2026-04 statement of card "Purple" has total R$ 600.00 and outstanding R$ 600.00
    And the 2026-05 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2027-01 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2027-02 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00

  @FAT-4 @EST-1 @FAT-10 @edge
  Scenario: A refund falls into the cycle of its own date, not the purchase's
    Given today is 2026-04-06
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 300.00 on card "Purple" on 2026-04-05 linked to the purchase "Sneakers"
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-04 statement of card "Purple" is "closed"
    And the 2026-05 statement of card "Purple" has total -R$ 300.00 and outstanding -R$ 300.00
    And the total debt of card "Purple" is R$ 0.00
