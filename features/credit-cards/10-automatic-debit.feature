Feature: Recurring transfer to the card
  Each occurrence links to the statement with the first due date ≥ the occurrence date.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01

  @FAT-14 @edge
  Scenario Outline: Link of each occurrence to the statement
    Given the recurring transfer "Autopay" of R$ 300.00 from account "Nubank" to card "<card>", monthly, starting <start>, with no end
    Then the <start> occurrence of series "Autopay" is linked to the <statement> statement of card "<card>"
    And the <second> occurrence of series "Autopay" is linked to the <next statement> statement of card "<card>"

    Examples:
      | card   | start      | statement | second     | next statement | case                     |
      | Purple | 2026-04-05 | 2026-04   | 2026-05-05 | 2026-05        | before the due date      |
      | Purple | 2026-04-10 | 2026-04   | 2026-05-10 | 2026-05        | on the due day (≥)       |
      | Purple | 2026-04-11 | 2026-05   | 2026-05-11 | 2026-06        | after the due date: next |
      | Black  | 2026-04-06 | 2026-05   | 2026-05-06 | 2026-06        | Black due on day 5       |

  @FAT-14 @FAT-6 @FAT-8
  Scenario: A planned automatic debit replaces the derived outflow
    Given the daily amount is R$ 0.00 since 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the recurring transfer "Autopay" of R$ 300.00 from account "Nubank" to card "Purple", monthly, starting 2026-04-10, with no end
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00
