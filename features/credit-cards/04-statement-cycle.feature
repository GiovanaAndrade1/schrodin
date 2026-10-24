Feature: Which statement each purchase falls into
  The statement that closes on F contains the purchases dated in [previous F, F). Day 29/30/31 in a short month becomes the last day of the month.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the card "Blue" with limit R$ 5,000.00, closing day 31, due day 8, payment account "Nubank" and start date 2026-01-01
    And the card "Thirty" with limit R$ 5,000.00, closing day 30, due day 5, payment account "Nubank" and start date 2026-01-01
    And the card "Twenty-Nine" with limit R$ 5,000.00, closing day 29, due day 5, payment account "Nubank" and start date 2026-01-01

  @FAT-1 @FAT-3 @CAR-2 @edge
  Scenario Outline: Purchase allocation to the cycle (2026/2027, no leap year)
    When I add the purchase "Item" of R$ 100.00 to card "<card>" on <date>
    Then the purchase "Item" is in the <statement> statement of card "<card>"
    And the <statement> statement of card "<card>" closes on <closes> and is due on <due>

    Examples: regular day
      | card   | date       | statement | closes     | due        | case                                |
      | Purple | 2026-03-03 | 2026-04   | 2026-04-03 | 2026-04-10 | on the previous closing date: opens |
      | Purple | 2026-04-02 | 2026-04   | 2026-04-03 | 2026-04-10 | day before the closing date         |
      | Purple | 2026-04-03 | 2026-05   | 2026-05-03 | 2026-05-10 | closing day: next                   |
      | Purple | 2026-12-31 | 2027-01   | 2027-01-03 | 2027-01-10 | year rollover                       |
      | Black  | 2026-03-27 | 2026-04   | 2026-03-28 | 2026-04-05 | day before the closing date         |
      | Black  | 2026-03-28 | 2026-05   | 2026-04-28 | 2026-05-05 | closing day: next                   |
      | Black  | 2026-12-27 | 2027-01   | 2026-12-28 | 2027-01-05 | due in the next year                |
      | Black  | 2026-12-28 | 2027-02   | 2027-01-28 | 2027-02-05 | December closing                    |

    Examples: closing day 29, 30 and 31 in a short month
      | card        | date       | statement | closes     | due        | case                                  |
      | Blue        | 2026-02-28 | 2026-04   | 2026-03-31 | 2026-04-08 | closed on 02-28 (31 becomes 28): next |
      | Blue        | 2026-03-30 | 2026-04   | 2026-03-31 | 2026-04-08 | day before day 31                     |
      | Blue        | 2026-03-31 | 2026-05   | 2026-04-30 | 2026-05-08 | day 31: next                          |
      | Blue        | 2026-04-29 | 2026-05   | 2026-04-30 | 2026-05-08 | day before in a 30-day month          |
      | Blue        | 2026-04-30 | 2026-06   | 2026-05-31 | 2026-06-08 | 31 becomes 30 in April: next          |
      | Blue        | 2027-02-27 | 2027-03   | 2027-02-28 | 2027-03-08 | day before 31 turned 28               |
      | Blue        | 2027-02-28 | 2027-04   | 2027-03-31 | 2027-04-08 | 31 turned 28: next                    |
      | Thirty      | 2026-04-29 | 2026-05   | 2026-04-30 | 2026-05-05 | day before day 30                     |
      | Thirty      | 2026-04-30 | 2026-06   | 2026-05-30 | 2026-06-05 | day 30: next                          |
      | Thirty      | 2027-02-27 | 2027-03   | 2027-02-28 | 2027-03-05 | 30 becomes 28 in February             |
      | Thirty      | 2027-02-28 | 2027-04   | 2027-03-30 | 2027-04-05 | 30 turned 28: next                    |
      | Twenty-Nine | 2027-02-27 | 2027-03   | 2027-02-28 | 2027-03-05 | 29 becomes 28 in February             |
      | Twenty-Nine | 2027-02-28 | 2027-04   | 2027-03-29 | 2027-04-05 | 29 turned 28: next                    |

  @FAT-1 @FAT-3 @CAR-2 @edge
  Scenario Outline: Purchase allocation in February of a leap year (2028)
    Given today is 2028-01-20
    When I add the purchase "Item" of R$ 100.00 to card "<card>" on <date>
    Then the purchase "Item" is in the <statement> statement of card "<card>"
    And the <statement> statement of card "<card>" closes on <closes> and is due on <due>

    Examples:
      | card        | date       | statement | closes     | due        |
      | Twenty-Nine | 2028-02-28 | 2028-03   | 2028-02-29 | 2028-03-05 |
      | Twenty-Nine | 2028-02-29 | 2028-04   | 2028-03-29 | 2028-04-05 |
      | Thirty      | 2028-02-28 | 2028-03   | 2028-02-29 | 2028-03-05 |
      | Thirty      | 2028-02-29 | 2028-04   | 2028-03-30 | 2028-04-05 |
      | Blue        | 2028-02-28 | 2028-03   | 2028-02-29 | 2028-03-08 |
      | Blue        | 2028-02-29 | 2028-04   | 2028-03-31 | 2028-04-08 |
      | Black       | 2028-02-27 | 2028-03   | 2028-02-28 | 2028-03-05 |
      | Black       | 2028-02-28 | 2028-04   | 2028-03-28 | 2028-04-05 |
      | Black       | 2028-02-29 | 2028-04   | 2028-03-28 | 2028-04-05 |

  @FAT-13 @FAT-1 @edge
  Scenario Outline: The current open statement changes on the closing day
    Given today is <today>
    Then the current open statement of card "<card>" is the <statement> one

    Examples:
      | today      | card   | statement |
      | 2026-04-02 | Purple | 2026-04   |
      | 2026-04-03 | Purple | 2026-05   |
      | 2026-03-27 | Black  | 2026-04   |
      | 2026-03-28 | Black  | 2026-05   |
      | 2026-04-29 | Blue   | 2026-05   |
      | 2026-04-30 | Blue   | 2026-06   |

  @FAT-13 @PAR-1
  Scenario: Statements after the current open one are future
    When I add the purchase "TV" of R$ 3,000.00 to card "Purple" on 2026-03-10 in 10 installments
    Then the current open statement of card "Purple" is the 2026-04 one
    And the statements from 2026-05 to 2027-01 of card "Purple" are future
