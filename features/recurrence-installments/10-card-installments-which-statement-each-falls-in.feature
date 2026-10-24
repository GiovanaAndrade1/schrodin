Feature: Card installments, one per statement
  Background:
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the card "Inter" with limit R$ 3,000.00, closing day 31, due day 10, payment account "Nubank" and start date 2026-01-01

  @PAR-1 @FAT-1 @FAT-3
  Scenario: Installments of the 10-installment TV crossing the year
    Given today is 2026-03-15
    When I add the purchase "TV" of R$ 3,000.00 to card "Purple" on 2026-03-10 in 10 installments
    Then the installments of the purchase "TV" are:
      | k  | amount    | statement |
      | 1  | R$ 300.00 | 2026-04   |
      | 2  | R$ 300.00 | 2026-05   |
      | 3  | R$ 300.00 | 2026-06   |
      | 4  | R$ 300.00 | 2026-07   |
      | 5  | R$ 300.00 | 2026-08   |
      | 6  | R$ 300.00 | 2026-09   |
      | 7  | R$ 300.00 | 2026-10   |
      | 8  | R$ 300.00 | 2026-11   |
      | 9  | R$ 300.00 | 2026-12   |
      | 10 | R$ 300.00 | 2027-01   |

  @PAR-1 @PAR-2 @FAT-1 @edge
  Scenario: A purchase on the Black closing day in November, with the remainder in the first one
    Given today is 2026-11-28
    When I add the purchase "Fridge" of R$ 1,000.00 to card "Black" on 2026-11-28 in 6 installments
    Then the installments of the purchase "Fridge" are:
      | k | amount    | statement |
      | 1 | R$ 166.70 | 2027-01   |
      | 2 | R$ 166.66 | 2027-02   |
      | 3 | R$ 166.66 | 2027-03   |
      | 4 | R$ 166.66 | 2027-04   |
      | 5 | R$ 166.66 | 2027-05   |
      | 6 | R$ 166.66 | 2027-06   |

  @PAR-1 @FAT-1 @FAT-3 @CAR-2 @edge
  Scenario Outline: Statement of the first and the last installment
    Given today is <date>
    When I add the purchase "Test" of R$ 900.00 to card "<card>" on <date> in <N> installments
    Then installment 1 of the purchase "Test" is in the <first> statement of card "<card>"
    And installment <N> of the purchase "Test" is in the <last> statement of card "<card>"

    Examples:
      | card   | date       | N  | first   | last    |
      | Purple | 2026-04-02 | 3  | 2026-04 | 2026-06 |
      | Purple | 2026-04-03 | 3  | 2026-05 | 2026-07 |
      | Purple | 2026-04-04 | 3  | 2026-05 | 2026-07 |
      | Purple | 2026-12-02 | 2  | 2026-12 | 2027-01 |
      | Purple | 2026-12-03 | 2  | 2027-01 | 2027-02 |
      | Purple | 2026-03-15 | 72 | 2026-04 | 2032-03 |
      | Black  | 2026-03-27 | 3  | 2026-04 | 2026-06 |
      | Black  | 2026-03-28 | 3  | 2026-05 | 2026-07 |
      | Black  | 2026-11-27 | 6  | 2026-12 | 2027-05 |
      | Black  | 2026-02-27 | 2  | 2026-03 | 2026-04 |
      | Black  | 2026-02-28 | 2  | 2026-04 | 2026-05 |
      | Inter  | 2026-01-30 | 3  | 2026-02 | 2026-04 |
      | Inter  | 2026-01-31 | 3  | 2026-03 | 2026-05 |
      | Inter  | 2026-02-28 | 3  | 2026-04 | 2026-06 |
      | Inter  | 2026-04-30 | 2  | 2026-06 | 2026-07 |

  @PAR-1 @FAT-1 @CAR-2 @edge
  Scenario: Installments follow consecutive statements, not the accrual date
    Given today is 2026-01-30
    When I add the purchase "Chair" of R$ 900.00 to card "Inter" on 2026-01-30 in 3 installments
    Then the installments of the purchase "Chair" are:
      | k | amount    | accrual date | statement |
      | 1 | R$ 300.00 | 2026-01-30   | 2026-02   |
      | 2 | R$ 300.00 | 2026-02-28   | 2026-03   |
      | 3 | R$ 300.00 | 2026-03-30   | 2026-04   |

  @PAR-6 @STA-6 @LIM-1
  Scenario: A confirmed installment purchase uses the full limit right away
    Given today is 2026-03-15
    When I add the purchase "TV" of R$ 3,000.00 to card "Purple" on 2026-03-10 in 10 installments
    Then the 10 installments of the purchase "TV" are "confirmed"
    And the available limit of card "Purple" is R$ 2,000.00

  @PAR-6 @LIM-1
  Scenario: Paying the statement frees the installment's limit
    Given today is 2026-04-08
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08
    Then the available limit of card "Purple" is R$ 2,300.00

  @PAR-6 @STA-6 @LIM-3
  Scenario: A future installment purchase is planned and only uses the limit when the date arrives
    Given today is 2026-03-15
    When I add the purchase "Laptop" of R$ 4,000.00 to card "Purple" on 2026-04-20 in 10 installments
    Then the 10 installments of the purchase "Laptop" are "planned", of R$ 400.00, in the statements from 2026-05 to 2027-02
    And the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Purple" after planned entries is R$ 1,000.00
    When the day turns to 2026-04-20
    Then the 10 installments of the purchase "Laptop" are "confirmed"
    And the available limit of card "Purple" is R$ 1,000.00
    And I see the warning "The purchase 'Laptop' was confirmed; delete it if it didn't happen"

  @PAR-6 @LIM-2
  Scenario: An installment purchase above the limit is allowed with a warning
    Given today is 2026-03-15
    When I add the purchase "Phone" of R$ 6,000.00 to card "Purple" on 2026-03-15 in 12 installments
    Then I see the warning "This purchase exceeds the available limit"
    And the purchase "Phone" has 12 installments of R$ 500.00
    And the available limit of card "Purple" is -R$ 1,000.00
