Feature: Account refunds in the indicators

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the expense "Shoes" of R$ 300.00 in account "Nubank" on 2026-03-05, confirmed
    And the expense "Groceries" of R$ 200.00 in account "Nubank" on 2026-03-06, confirmed, as daily spending

  @EST-7 @IND-1 @IND-2 @IND-3 @CON-4
  Scenario Outline: An account refund reduces Outflows or Daily spending, is not an Inflow, and counts in the balance
    When I add the account refund "Return" of <amount> to account "Nubank" on 2026-03-12 linked to the expense "<expense>"
    Then the realized Outflows for 2026-03 are <outflows>
    And the realized Daily spending for 2026-03 is <daily spending>
    And the realized Inflows for 2026-03 are R$ 0.00
    And the actual balance of account "Nubank" is <balance>

    Examples:
      | amount    | expense   | outflows  | daily spending | balance   |
      | R$ 50.00  | Shoes     | R$ 250.00 | R$ 200.00      | R$ 550.00 |
      | R$ 300.00 | Shoes     | R$ 0.00   | R$ 200.00      | R$ 800.00 |
      | R$ 30.00  | Groceries | R$ 300.00 | R$ 170.00      | R$ 530.00 |

  @EST-7 @EST-4 @error
  Scenario: Linked account refunds do not exceed the expense amount
    Given the account refund "Part" of R$ 200.00 in account "Nubank" on 2026-03-10 linked to the expense "Shoes"
    When I add the account refund "Rest" of R$ 100.01 to account "Nubank" on 2026-03-12 linked to the expense "Shoes"
    Then the operation is blocked with the message "The account refunds for this expense would exceed its amount (R$ 300.00)"

  @EST-7 @error
  Scenario: An account refund only links to an expense in the same account
    Given the expense "Pastry" of R$ 15.00 in account "Wallet" on 2026-03-07, confirmed
    When I add the account refund "Pastry" of R$ 15.00 to account "Nubank" on 2026-03-12 linked to the expense "Pastry"
    Then the operation is blocked with the message "The account refund must be in the same account as the expense"

  @EST-7 @EST-3 @edge
  Scenario: An account refund in a later month reduces the account refund's month
    Given the expense "Headphones" of R$ 250.00 in account "Nubank" on 2026-02-20, confirmed
    And the account refund "Headphones" of R$ 250.00 in account "Nubank" on 2026-03-02 linked to the expense "Headphones"
    Then the realized Outflows for 2026-02 are R$ 250.00
    And the realized Outflows for 2026-03 are R$ 50.00
