Feature: Statement identity, label and due date
  Identity = card + cycle sequence number. Label = month of the due date. Due date = first occurrence of the due day strictly after the closing date.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01

  @FAT-3 @FAT-0 @CAR-2 @edge
  Scenario Outline: Due date and label from the closing date
    Given the card "Test" with limit R$ 5,000.00, closing day <closing day>, due day <due day> and payment account "Nubank"
    Then the calendar of card "Test" has the statement closing on <closes>, due on <due> and with label <label>

    Examples:
      | closing day | due day | closes     | due        | label   | case                                        |
      | 3           | 10      | 2026-04-03 | 2026-04-10 | 2026-04 | due > closes: same month                    |
      | 28          | 5       | 2026-03-28 | 2026-04-05 | 2026-04 | due < closes: next month                    |
      | 10          | 10      | 2026-04-10 | 2026-05-10 | 2026-05 | due = closes: next month (strict)           |
      | 31          | 7       | 2026-04-30 | 2026-05-07 | 2026-05 | closes on 31 in a 30-day month              |
      | 25          | 31      | 2026-04-25 | 2026-04-30 | 2026-04 | due 31 becomes 30                           |
      | 25          | 31      | 2026-02-25 | 2026-02-28 | 2026-02 | due 31 becomes 28                           |
      | 31          | 30      | 2026-01-31 | 2026-02-28 | 2026-02 | due 30 becomes 28, after 01-31              |
      | 31          | 30      | 2026-02-28 | 2026-03-30 | 2026-03 | closes on 31, becomes 28                    |
      | 29          | 1       | 2026-02-28 | 2026-03-01 | 2026-03 | closes on 29, becomes 28, due the next day  |
      | 1           | 31      | 2026-02-01 | 2026-02-28 | 2026-02 | due 31 becomes 28                           |
      | 31          | 29      | 2026-01-31 | 2026-02-28 | 2026-02 | due 29 becomes 28 (2026 is not a leap year) |
      | 31          | 29      | 2028-01-31 | 2028-02-29 | 2028-02 | due 29 exists in 2028                       |
      | 20          | 30      | 2028-02-20 | 2028-02-29 | 2028-02 | due 30 becomes 29 in 2028                   |
      | 28          | 31      | 2026-02-28 | 2026-03-31 | 2026-03 | due turned 28 is not after 28: skips        |

  @FAT-0 @FAT-3 @CAR-2 @edge
  Scenario: Two statements with the same due date because of February
    Given the card "Collision" with limit R$ 5,000.00, closing day 30, due day 31, payment account "Nubank" and start date 2026-01-01
    Then the calendar of card "Collision" has the statement closing on 2026-02-28 and due on 2026-03-31
    And the calendar of card "Collision" has the statement closing on 2026-03-30 and due on 2026-03-31
    And the two statements are consecutive and distinct cycles
    And the labels are "due 03-31 · closed 02-28" and "due 03-31 · closed 03-30"
