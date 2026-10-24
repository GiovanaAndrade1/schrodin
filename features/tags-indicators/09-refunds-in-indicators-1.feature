# Check: Untagged = Sneakers 300.00 + Snack 40.00 = 340.00. Σ expenses = 120.00 − 50.00 + 340.00 = 410.00 = Total outflows (Outflows 300 + 120 − 50 = 370.00; Daily spending 40.00).
#
#
#
# Cancellation check: installments of R$ 400.00 with accrual dates 2026-01-10, 2026-02-10, 2026-03-10. Closed: 1 and 2 → 800.00; installment 3 is cancelled. Difference = 800 − refunds already linked. Prior 100: refund 700; Feb 400 − 100 = 300; net 400 + 300 − 700 = 0. Prior 800: nothing; Feb 400 − 800 = −400; net 400 − 400 = 0. Prior 1,000: charge of 200; Feb 400 − 1,000 = −600; Mar +200; net 400 − 600 + 200 = 0. No prior: refund 800; 400 + 400 − 800 = 0.
#
#
#
# Account refund check: balance before = 1,000 − 300 − 200 = 500.00; + account refund. Later month: March = Shoes 300 − Headphones 250 = 50.00 (Groceries is daily spending).
Feature: Card refunds in the indicators

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-05
    And the purchase "Snack" of R$ 40.00 on card "Purple" on 2026-03-06, as daily spending

  @EST-3 @IND-1 @IND-2 @IND-3
  Scenario Outline: A refund reduces Outflows or Daily spending according to the linked purchase, never becomes an Inflow
    Given the refund "Return" of <amount> on card "Purple" on 2026-03-12 <link>
    Then the realized Outflows for 2026-03 are <outflows>
    And the realized Daily spending for 2026-03 is <daily spending>
    And the realized Inflows for 2026-03 are R$ 0.00

    Examples:
      | amount    | link                              | outflows  | daily spending |
      | R$ 100.00 | linked to the purchase "Sneakers" | R$ 200.00 | R$ 40.00       |
      | R$ 15.00  | linked to the purchase "Snack"    | R$ 300.00 | R$ 25.00       |
      | R$ 15.00  | unlinked                          | R$ 285.00 | R$ 40.00       |
      | R$ 40.00  | linked to the purchase "Snack"    | R$ 300.00 | R$ 0.00        |

  @EST-3 @IND-2 @IND-3
  Scenario: A refund follows the current flag of the linked purchase
    Given the refund "Snack" of R$ 15.00 on card "Purple" on 2026-03-12 linked to the purchase "Snack"
    When I uncheck "as daily spending" on the purchase "Snack"
    Then the realized Outflows for 2026-03 are R$ 325.00
    And the realized Daily spending for 2026-03 is R$ 0.00

  @EST-1 @TAG-9
  Scenario: A linked refund comes with the purchase's tags and counts in its own tags
    Given the tag "clothing"
    And the tag "gift"
    And the purchase "Shirt" of R$ 120.00 on card "Purple" on 2026-03-07 with the tag "clothing"
    When I add the refund "Shirt" of R$ 50.00 to card "Purple" on 2026-03-13 linked to the purchase "Shirt"
    Then the refund "Shirt" has the tags "clothing"
    When I switch the tags of the refund "Shirt" to "gift"
    Then the realized tag report for 2026-03 shows:
      | tag      | expenses  | income  |
      | clothing | R$ 120.00 | R$ 0.00 |
      | gift     | -R$ 50.00 | R$ 0.00 |
      | Untagged | R$ 340.00 | R$ 0.00 |
