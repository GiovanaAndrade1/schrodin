Feature: The same daily spending routine with the source in the account or on the card
  The daily budget source changes WHEN the reserve leaves the cash, not HOW MUCH.
  Statement, limit and indicators must not change with the source.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the projection horizon is 1 month
    And the tag "groceries" that marks daily spending

  @integration @DIA-5 @DIA-7 @DIA-8 @DIA-10 @FAT-4 @FAT-6 @LIM-1 @PRJ-3 @PRJ-7 @TER-1 @IND-3 @IND-11
  Scenario Outline: Same routine, different projections
    Given the daily budget source is <source>
    And the purchase "Groceries" of R$ 30.00 on card "Purple" on 2026-03-15 with the tag "groceries"
    And the expense "Bakery" of R$ 20.00 in account "Nubank" on 2026-03-20, planned, with the tag "groceries"
    Then the daily reserve on 2026-03-15 is R$ 20.00
    And the daily reserve on 2026-03-20 is R$ 30.00
    And the 2026-04 statement of card "Purple" has total R$ 30.00
    And the available limit of card "Purple" is R$ 4,970.00
    And the derived outflow of the 2026-04 statement of card "Purple" is <outflow April> on 2026-04-10
    And the reserve for the days from 2026-04-03 to 2026-04-15, R$ 650.00, <where it goes>
    And the consolidated projected balance is:
      | date       | balance |
      | 2026-03-15 | <d0315> |
      | 2026-03-20 | <d0320> |
      | 2026-04-09 | <d0409> |
      | 2026-04-10 | <d0410> |
      | 2026-04-15 | <d0415> |
    And the thermometer color on 2026-03-15 is "<color today>"
    And the lowest future balance is <lowest> on <earlier date>
    And the forecast Daily spending for 2026-03 is R$ 50.00
    And the realized Daily spending for 2026-03 is R$ 30.00

    Examples:
      | source              | outflow April | where it goes                                                                                                | d0315       | d0320       | d0409       | d0410       | d0415       | color today | lowest      | earlier date |
      | the default account | R$ 30.00      | leaves spending account "Nubank"                                                                             | R$ 1,980.00 | R$ 1,730.00 | R$ 730.00   | R$ 650.00   | R$ 400.00   | light green | R$ 400.00   | 2026-04-15   |
      | card "Purple"       | R$ 930.00     | stays in the 2026-05 statement and appears as "R$ 650.00 of daily spending in statements beyond the horizon" | R$ 2,000.00 | R$ 1,980.00 | R$ 1,980.00 | R$ 1,050.00 | R$ 1,050.00 | dark green  | R$ 1,050.00 | 2026-04-10   |

  @integration @DIA-6 @DIA-10 @GER-3 @FAT-6 @PRJ-8
  Scenario Outline: The midnight rollover releases yesterday's surplus in different places
    Given the daily budget source is <source>
    And the purchase "Groceries" of R$ 30.00 on card "Purple" on 2026-03-15 with the tag "groceries"
    And the expense "Bakery" of R$ 20.00 in account "Nubank" on 2026-03-20, planned, with the tag "groceries"
    When the day turns to 2026-03-16
    Then there is no daily reserve on 2026-03-15
    And I see "surplus from yesterday's daily budget: R$ 20.00"
    And the derived outflow of the 2026-04 statement of card "Purple" is <outflow April> on 2026-04-10
    And the consolidated projected balance on 2026-03-16 is <d0316>
    And the consolidated projected balance on 2026-04-10 is <d0410>

    Examples:
      | source              | outflow April | d0316       | d0410       |
      | the default account | R$ 30.00      | R$ 1,950.00 | R$ 670.00   |
      | card "Purple"       | R$ 910.00     | R$ 2,000.00 | R$ 1,070.00 |

  @integration @DIA-5 @DIA-8 @DIA-10 @FAT-1 @FAT-5 @FAT-6 @GER-3
  Scenario: Card source on the rollover to the closing day
    Given today is 2026-04-02
    And the projection horizon is 2 months
    And the daily budget source is card "Purple"
    And the purchase "Sneakers" of R$ 600.00 on card "Purple" on 2026-03-20
    Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 650.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,500.00 on 2026-05-10
    When the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" is "closed" with total R$ 600.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 600.00 on 2026-04-10
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,500.00 on 2026-05-10
    When I add the purchase "Market" of R$ 20.00 to card "Purple" on 2026-04-03 with the tag "groceries"
    Then the purchase "Market" is in the 2026-05 statement of card "Purple"
    And the daily reserve on 2026-04-03 is R$ 30.00
    And the 2026-05 statement of card "Purple" has total R$ 20.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,500.00 on 2026-05-10

  @integration @DIA-5 @DIA-7 @DIA-8 @PRJ-6 @LIM-1 @IND-3
  Scenario Outline: Daily spending in the account or on the card, with the account as source, converges on the due date
    Given the daily budget source is the default account
    When I add <entry> on 2026-03-15 with the tag "groceries"
    Then the daily reserve on 2026-03-15 is R$ 0.00
    And the actual balance of account "Nubank" is <actual>
    And the consolidated projected balance on 2026-03-15 is <today>
    And the consolidated projected balance on 2026-04-10 is R$ 620.00
    And the available limit of card "Purple" is <available>
    And the realized Daily spending for 2026-03 is R$ 80.00

    Examples:
      | entry                                                   | actual      | today       | available   |
      | the expense "Groceries" of R$ 80.00 to account "Nubank" | R$ 1,920.00 | R$ 1,920.00 | R$ 5,000.00 |
      | the purchase "Groceries" of R$ 80.00 to card "Purple"   | R$ 2,000.00 | R$ 2,000.00 | R$ 4,920.00 |

  @integration @DIA-5 @DIA-9 @EST-1 @EST-3 @FAT-11 @LIM-1 @IND-3
  Scenario: A same-day refund of a daily spending purchase does not give the reserve back
    Given the daily budget source is the default account
    When I add the purchase "Groceries" of R$ 80.00 to card "Purple" on 2026-03-15 with the tag "groceries"
    And I add the refund "Groceries" of R$ 80.00 to card "Purple" on 2026-03-15 linked to the purchase "Groceries"
    Then the daily reserve on 2026-03-15 is R$ 0.00
    And the 2026-04 statement of card "Purple" is "open" with total R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the consolidated projected balance on 2026-03-15 is R$ 2,000.00
    And the consolidated projected balance on 2026-04-15 is R$ 450.00
    And the realized Daily spending for 2026-03 is R$ 0.00
    And the daily budget from 2026-03-15 to 2026-03-15 has budgeted R$ 50.00, spent R$ 0.00 and surplus R$ 50.00

  @integration @FAT-5 @FAT-11 @FAT-4 @FAT-6 @DIA-10 @REC-9 @PRJ-7 @TER-2
  Scenario: A statement with no confirmed purchase stays in the projection through the reserve and the planned entries
    Given the projection horizon is 2 months
    And the daily budget source is card "Purple"
    And the recurring expense "Netflix" of R$ 55.90 on card "Purple", monthly, starting 2026-04-18, with no end
    Then the 2026-04 statement of card "Purple" has total R$ 0.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 950.00 on 2026-04-10
    And the 2026-05 statement of card "Purple" has total R$ 0.00 and shows "+ R$ 55.90 planned"
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,555.90 on 2026-05-10
    And both are "open", because the closing date has not arrived yet
    And next to the lowest balance "R$ 650.00 of daily spending in statements beyond the horizon" appears
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-04-09 | R$ 2,000.00 | dark green  |
      | 2026-04-10 | R$ 1,050.00 | light green |
      | 2026-05-10 | -R$ 505.90  | red         |
      | 2026-05-15 | -R$ 505.90  | red         |
    And the first negative day is 2026-05-10
