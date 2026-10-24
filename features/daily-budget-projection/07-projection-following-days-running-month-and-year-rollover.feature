Feature: Day-by-day projection
  As a user
  I want to see the balance of each day up to the horizon
  In order to know when money gets tight

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 150.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 8,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the projection horizon is 1 month

  @PRJ-3 @PRJ-4 @PRJ-5 @PRJ-6 @FAT-6 @DIA-7 @TRF-7
  Scenario: Realistic month day by day (salary, rent, statements, transfers, daily budget)
    Given the purchase "Big Groceries" of R$ 600.00 on card "Purple" on 2026-03-05
    And the purchase "Pharmacy" of R$ 150.00 on card "Purple" on 2026-03-20
    And the purchase "Ticket" of R$ 1,200.00 on card "Black" on 2026-03-10 in 3 installments
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-20, planned
    And the transfer "Change" of R$ 200.00 from account "Nubank" to account "Wallet" on 2026-03-25, planned
    And the transfer "Save" of R$ 300.00 from account "Nubank" to account "Reserve" on 2026-03-31, planned
    And the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-04-01, planned
    Then the 2026-04 statement of card "Purple" has total R$ 600.00 and shows "+ R$ 150.00 planned"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 750.00 on 2026-04-10
    And the derived outflow of the 2026-04 statement of card "Black" is R$ 400.00 on 2026-04-05
    And the 2026-04 statement of card "Black" closes on 2026-03-28 and is due on 2026-04-05
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 2,100.00 |
      | 2026-03-16 | R$ 2,050.00 |
      | 2026-03-17 | R$ 2,000.00 |
      | 2026-03-18 | R$ 1,950.00 |
      | 2026-03-19 | R$ 1,900.00 |
      | 2026-03-20 | R$ 350.00   |
      | 2026-03-24 | R$ 150.00   |
      | 2026-03-25 | R$ 100.00   |
      | 2026-03-26 | R$ 50.00    |
      | 2026-03-27 | R$ 0.00     |
      | 2026-03-28 | -R$ 50.00   |
      | 2026-03-30 | -R$ 150.00  |
      | 2026-03-31 | -R$ 500.00  |
      | 2026-04-01 | R$ 4,450.00 |
      | 2026-04-04 | R$ 4,300.00 |
      | 2026-04-05 | R$ 3,850.00 |
      | 2026-04-09 | R$ 3,650.00 |
      | 2026-04-10 | R$ 2,850.00 |
      | 2026-04-15 | R$ 2,600.00 |
    And the projected balance per account is:
      | date       | Nubank      | Wallet    | Reserve     |
      | 2026-03-20 | R$ 200.00   | R$ 150.00 | R$ 8,000.00 |
      | 2026-03-25 | -R$ 250.00  | R$ 350.00 | R$ 8,000.00 |
      | 2026-03-31 | -R$ 850.00  | R$ 350.00 | R$ 8,300.00 |
      | 2026-04-10 | R$ 2,500.00 | R$ 350.00 | R$ 8,300.00 |
    And the lowest future balance is -R$ 500.00 on 2026-03-31
    And the first negative day is 2026-03-28

  @TER-1 @TER-2
  Scenario: Thermometer over the realistic month
    Given the purchase "Big Groceries" of R$ 600.00 on card "Purple" on 2026-03-05
    And the purchase "Pharmacy" of R$ 150.00 on card "Purple" on 2026-03-20
    And the purchase "Ticket" of R$ 1,200.00 on card "Black" on 2026-03-10 in 3 installments
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-20, planned
    And the transfer "Change" of R$ 200.00 from account "Nubank" to account "Wallet" on 2026-03-25, planned
    And the transfer "Save" of R$ 300.00 from account "Nubank" to account "Reserve" on 2026-03-31, planned
    And the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-04-01, planned
    Then the thermometer colors are:
      | date       | balance     | color       |
      | 2026-03-17 | R$ 2,000.00 | dark green  |
      | 2026-03-18 | R$ 1,950.00 | light green |
      | 2026-03-20 | R$ 350.00   | yellow      |
      | 2026-03-27 | R$ 0.00     | yellow      |
      | 2026-03-28 | -R$ 50.00   | pink        |
      | 2026-03-31 | -R$ 500.00  | pink        |
      | 2026-04-01 | R$ 4,450.00 | dark green  |

  @PRJ-4 @PRJ-3 @FAT-1 @FAT-3 @edge
  Scenario: The year rollover does not reset the balance and a statement crosses the year
    Given today is 2026-12-28
    And the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-12-01
    And "Itaú" is the default account
    And I change the default payment account of card "Black" to "Itaú"
    And the daily amount changes to R$ 20.00 from 2026-12-28
    And the projection horizon is 12 months
    And the purchase "Supper" of R$ 400.00 on card "Black" on 2026-12-27
    And the purchase "Trip" of R$ 600.00 on card "Black" on 2026-12-28
    And the expense "New Year's Eve" of R$ 300.00 in account "Itaú" on 2026-12-31, planned
    And the income "Salary" of R$ 3,000.00 in account "Itaú" on 2027-01-05, planned
    Then the purchase "Supper" is in the 2027-01 statement of card "Black"
    And the purchase "Trip" is in the 2027-02 statement of card "Black"
    And the projected balance of account "Itaú" is:
      | date       | balance     |
      | 2026-12-28 | R$ 980.00   |
      | 2026-12-30 | R$ 940.00   |
      | 2026-12-31 | R$ 620.00   |
      | 2027-01-01 | R$ 600.00   |
      | 2027-01-04 | R$ 540.00   |
      | 2027-01-05 | R$ 3,120.00 |
      | 2027-02-04 | R$ 2,520.00 |
      | 2027-02-05 | R$ 1,900.00 |

  @PRJ-3 @PRJ-4 @REC-4
  Scenario: Several months with recurring series up to the end of the 12-month horizon
    Given the projection horizon is 12 months
    And the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the recurring income "Salary" of R$ 5,000.00 in account "Itaú", monthly, starting 2026-01-05, with no end
    And the recurring expense "Rent" of R$ 1,500.00 in account "Itaú", monthly, starting 2026-01-10, with no end
    And the occurrences of "Salary" and "Rent" up to 2026-03-10, confirmed
    And the actual balance of account "Itaú" is R$ 11,500.00
    Then the projected balance of account "Itaú" is:
      | date       | balance      |
      | 2026-03-15 | R$ 11,500.00 |
      | 2026-04-04 | R$ 11,500.00 |
      | 2026-04-05 | R$ 16,500.00 |
      | 2026-04-10 | R$ 15,000.00 |
      | 2026-12-31 | R$ 43,000.00 |
      | 2027-01-05 | R$ 48,000.00 |
      | 2027-03-15 | R$ 53,500.00 |
    And there is no projected balance on 2027-03-16

  @PRJ-6 @FAT-1 @FAT-3 @STA-6
  Scenario Outline: A card purchase only appears in the account through the statement due date
    Given the daily amount changes to R$ 0.00 from 2026-03-15
    And the projection horizon is 12 months
    And the purchase "Purchase" of R$ 300.00 on card "<card>" on <purchase date>
    Then the purchase "Purchase" is "<status>"
    And the purchase "Purchase" is in the <statement> statement of card "<card>"
    And the projected balance of account "Nubank" on <purchase date> is R$ 2,000.00
    And the projected balance of account "Nubank" on <day before> is R$ 2,000.00
    And the projected balance of account "Nubank" on <due date> is R$ 1,700.00

    Examples:
      | card   | purchase date | status    | statement | day before | due date   |
      | Purple | 2026-03-15    | confirmed | 2026-04   | 2026-04-09 | 2026-04-10 |
      | Purple | 2026-04-02    | planned   | 2026-04   | 2026-04-09 | 2026-04-10 |
      | Purple | 2026-04-03    | planned   | 2026-05   | 2026-05-09 | 2026-05-10 |
      | Black  | 2026-03-27    | planned   | 2026-04   | 2026-04-04 | 2026-04-05 |
      | Black  | 2026-03-28    | planned   | 2026-05   | 2026-05-04 | 2026-05-05 |

  @PRJ-6 @PAR-1 @PAR-2
  Scenario: An installment purchase on a card leaves one installment per due date
    Given the daily amount changes to R$ 0.00 from 2026-03-15
    And the projection horizon is 12 months
    And the purchase "Phone" of R$ 1,000.00 on card "Purple" on 2026-03-15 in 3 installments
    Then the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-04-09 | R$ 2,000.00 |
      | 2026-04-10 | R$ 1,666.66 |
      | 2026-05-10 | R$ 1,333.33 |
      | 2026-06-10 | R$ 1,000.00 |
      | 2026-07-10 | R$ 1,000.00 |
