# Check: on 2026-03-15 Black's current open statement is the one that closes on 2026-03-28 and is due on 2026-04-05 (label 2026-04), where installment 2 already is. Installment 4 goes to it, but by accrual March still has installment 3 (R$ 750.00) and April installment 4 (R$ 750.00). Moving the Sneakers (2026-04 statement, open) to the next one leads to the 2026-05 one (closes 2026-05-03), which is not closed.
Feature: Accrual month of the indicators

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 10,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01

  @IND-2 @FAT-1 @FAT-3 @INV-3
  Scenario Outline: Accrual is the entry date in the account and the purchase date on the card, never the statement's
    Given <entry> of R$ 100.00 on <date>
    Then the entry "<title>" counts in the indicators for <accrual>
    And the entry "<title>" does not count in the indicators for any other month
    And the statement of the entry "<title>" is <statement>

    Examples:
      | entry                                         | title       | date       | accrual | statement                                    |
      | the expense "Electricity" in account "Nubank" | Electricity | 2026-02-28 | 2026-02 | none                                         |
      | the expense "Gas" in account "Nubank"         | Gas         | 2026-03-01 | 2026-03 | none                                         |
      | the purchase "Headphones" on card "Black"     | Headphones  | 2026-01-27 | 2026-01 | the 2026-02 one of card "Black" (due 02-05)  |
      | the purchase "Book" on card "Black"           | Book        | 2026-01-28 | 2026-01 | the 2026-03 one of card "Black" (due 03-05)  |
      | the purchase "Shoes" on card "Black"          | Shoes       | 2026-02-28 | 2026-02 | the 2026-04 one of card "Black" (due 04-05)  |
      | the purchase "Pen" on card "Purple"           | Pen         | 2026-02-02 | 2026-02 | the 2026-02 one of card "Purple" (due 02-10) |
      | the purchase "Backpack" on card "Purple"      | Backpack    | 2026-02-03 | 2026-02 | the 2026-03 one of card "Purple" (due 03-10) |

  @IND-2 @IND-11 @PAR-1 @REC-3 @edge
  Scenario: Installment k counts in the month of the purchase date + (k−1) months, with the end of month adjusted
    Given the purchase "Laptop" of R$ 3,000.00 on card "Black" on 2026-01-31 in 4 installments
    Then the installments of the purchase "Laptop" are:
      | k | amount    | accrual    | statement |
      | 1 | R$ 750.00 | 2026-01-31 | 2026-03   |
      | 2 | R$ 750.00 | 2026-02-28 | 2026-04   |
      | 3 | R$ 750.00 | 2026-03-31 | 2026-05   |
      | 4 | R$ 750.00 | 2026-04-30 | 2026-06   |
    And the realized Outflows for 2026-01 are R$ 750.00
    And the realized Outflows for 2026-02 are R$ 750.00
    And the forecast Outflows for 2026-03 are R$ 750.00
    And the forecast Outflows for 2026-04 are R$ 750.00
    And the realized Outflows for 2026-04 are R$ 0.00

  @IND-2 @PAR-1 @REC-3 @edge
  Scenario Outline: End-of-month and leap-year adjustment in the installments' accrual
    Given today is <today>
    And the purchase "Bicycle" of R$ 900.00 on card "Purple" on <purchase date> in 3 installments
    Then installment 2 of the purchase "Bicycle" has accrual date <installment 2>
    And installment 3 of the purchase "Bicycle" has accrual date <installment 3>

    Examples:
      | today      | purchase date | installment 2 | installment 3 |
      | 2026-03-15 | 2026-01-29    | 2026-02-28    | 2026-03-29    |
      | 2026-03-15 | 2026-01-30    | 2026-02-28    | 2026-03-30    |
      | 2026-03-15 | 2026-01-31    | 2026-02-28    | 2026-03-31    |
      | 2027-02-10 | 2027-01-31    | 2027-02-28    | 2027-03-31    |
      | 2028-02-10 | 2028-01-31    | 2028-02-29    | 2028-03-31    |

  @IND-2 @PAR-1 @PAR-2
  Scenario: Installment rounding shows up in the month of the first installment
    Given the purchase "Course" of R$ 1,000.00 on card "Purple" on 2026-03-10 in 3 installments
    Then the forecast Outflows for 2026-03 are R$ 333.34
    And the forecast Outflows for 2026-04 are R$ 333.33
    And the forecast Outflows for 2026-05 are R$ 333.33

  @IND-11 @STA-6
  Scenario: A confirmed installment of a future month is not realized until its accrual date arrives
    Given the purchase "Course" of R$ 1,000.00 on card "Purple" on 2026-03-10 in 3 installments
    Then installment 2 of the purchase "Course" is "confirmed"
    And the realized Outflows for 2026-03 are R$ 333.34
    And the realized Outflows for 2026-04 are R$ 0.00
    And the forecast Outflows for 2026-04 are R$ 333.33
    When the day turns to 2026-04-10
    Then the realized Outflows for 2026-04 are R$ 333.33

  @IND-11 @PAR-1 @edge
  Scenario: Realized compares the accrual date, not the month: an installment of the current month whose day has not arrived yet
    Given the purchase "Laptop" of R$ 3,000.00 on card "Black" on 2026-01-31 in 4 installments
    Then the realized Outflows for 2026-03 are R$ 0.00
    And the forecast Outflows for 2026-03 are R$ 750.00
    When the day turns to 2026-03-31
    Then the realized Outflows for 2026-03 are R$ 750.00

  @IND-2 @PAR-1 @PAR-8 @STA-5
  Scenario: An account installment keeps its accrual even when confirmed on another date
    Given the expense "Fridge" of R$ 1,800.00 in account "Nubank" in 3 installments with installment 1 on 2026-01-31, all switched to planned
    Then the installments of the expense "Fridge" have accrual dates 2026-01-31, 2026-02-28 and 2026-03-31
    And installment 2 of the expense "Fridge" is "overdue"
    When I confirm installment 2 of the expense "Fridge" with amount R$ 600.00 on 2026-03-02
    Then the realized Outflows for 2026-02 are R$ 600.00
    And installment 2 of the expense "Fridge" does not count in the indicators for 2026-03

  @IND-2 @FAT-2
  Scenario: Moving the purchase to another statement does not change the accrual
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I move the purchase "Sneakers" to the next statement
    Then the purchase "Sneakers" is in the 2026-05 statement of card "Purple"
    And the entry "Sneakers" counts in the indicators for 2026-03
    And the forecast Outflows for 2026-04 are R$ 0.00

  @IND-2 @PAR-5
  Scenario: Prepaying an installment changes the statement, not the accrual
    Given the purchase "Laptop" of R$ 3,000.00 on card "Black" on 2026-01-31 in 4 installments
    When I prepay installment 4 of the purchase "Laptop" into the current open statement
    Then installment 4 of the purchase "Laptop" is in the 2026-04 statement of card "Black"
    And installment 4 of the purchase "Laptop" has accrual date 2026-04-30
    And the forecast Outflows for 2026-03 are R$ 750.00
    And the forecast Outflows for 2026-04 are R$ 750.00

  @IND-2 @TAG-9
  Scenario: The tag report uses the installment's accrual
    Given the tag "electronics"
    And the purchase "Laptop" of R$ 3,000.00 on card "Black" on 2026-01-31 in 4 installments with the tag "electronics"
    Then the realized tag report for 2026-02 shows:
      | tag         | expenses  | income  |
      | electronics | R$ 750.00 | R$ 0.00 |
    And the list for tag "electronics" in 2026-02 shows "Laptop (2/4)" with R$ 750.00
