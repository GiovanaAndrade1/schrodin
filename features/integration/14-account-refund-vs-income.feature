Feature: Money coming back from an expense paid from an account

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-03-01
    And "Nubank" is the default account
    And the daily amount is R$ 0.00 since 2026-03-01
    And the thermometer is in relative mode with the default multipliers
    And the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-05, confirmed, with the tag "salary"
    And the expense "Sneakers" of R$ 400.00 in account "Nubank" on 2026-03-05, confirmed, with the tag "leisure"
    And the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-06, confirmed

  @integration @EST-7 @EST-3 @LAN-3 @IND-1 @IND-2 @IND-5 @IND-7 @IND-8 @TAG-9 @TER-4 @INV-2 @INV-8
  Scenario Outline: Same money, same balance, different indicators
    When I add <entry>
    Then the actual balance of account "Nubank" is R$ 6,500.00
    And the consolidated projected balance on 2026-03-15 is R$ 6,500.00
    And the realized Inflows for 2026-03 are <inflows>
    And the realized Outflows for 2026-03 are <outflows>
    And the realized Performance for 2026-03 is R$ 5,000.00
    And the realized savings rate for 2026-03 is <saved>
    And the realized tag report for 2026-03 shows the tag "leisure" with expenses <leisure>
    And the sum of the income column of the realized tag report for 2026-03 is <income>
    When the day turns to 2026-04-01
    Then the cost of living is <cost>
    And the thermometer <thermometer>

    Examples:
      | entry                                                                                                         | inflows     | outflows  | saved | leisure   | income      | cost      | thermometer                                                            |
      | the account refund "Sneakers" of R$ 400.00 to account "Nubank" on 2026-03-15 linked to the expense "Sneakers" | R$ 5,000.00 | R$ 0.00   | 10.0% | R$ 0.00   | R$ 5,000.00 | R$ 0.00   | uses the absolute thresholds and warns that the cost of living is zero |
      | the income "Sneakers Return" of R$ 400.00 to account "Nubank" on 2026-03-15                                   | R$ 5,400.00 | R$ 400.00 | 9.3%  | R$ 400.00 | R$ 5,400.00 | R$ 400.00 | has the thresholds "-R$ 50.00 · R$ 0.00 · R$ 100.00 · R$ 200.00"       |

  @integration @EST-7 @EST-4 @DIA-5 @DIA-9 @IND-3 @error
  Scenario: Account refund of a daily spending expense and the account refund cap
    Given the tag "groceries" that marks daily spending
    And the daily amount changes to R$ 50.00 from 2026-03-15
    And the expense "Bakery" of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed, with the tag "groceries"
    When I add the account refund "Bakery" of R$ 50.00 to account "Nubank" on 2026-03-15 linked to the expense "Bakery"
    Then the daily reserve on 2026-03-15 is R$ 0.00
    And the consolidated projected balance on 2026-03-15 is R$ 6,100.00
    And the realized Daily spending for 2026-03 is R$ 0.00
    And the daily budget from 2026-03-15 to 2026-03-15 has budgeted R$ 50.00, spent R$ 0.00 and surplus R$ 50.00
    When I add the account refund "Bakery 2" of R$ 0.01 to account "Nubank" on 2026-03-15 linked to the expense "Bakery"
    Then the operation is blocked with the message "The account refunds for Bakery add up to at most R$ 50.00"

  @integration @EST-7 @EST-3 @IND-2 @IND-5 @IND-8 @TER-4
  Scenario Outline: Money that comes back the next month
    Given today is 2026-04-02
    When I add <entry>
    Then the realized Outflows for 2026-03 are still R$ 400.00
    And the realized Outflows for 2026-04 are <outflows April>
    And the realized Inflows for 2026-04 are <inflows April>
    And the realized Performance for 2026-04 is R$ 400.00
    When the day turns to 2026-05-01
    Then the cost of living is <cost>

    Examples:
      | entry                                                                                                         | outflows April | inflows April | cost      |
      | the account refund "Sneakers" of R$ 400.00 to account "Nubank" on 2026-04-02 linked to the expense "Sneakers" | -R$ 400.00     | R$ 0.00       | R$ 0.00   |
      | the income "Sneakers Return" of R$ 400.00 to account "Nubank" on 2026-04-02                                   | R$ 0.00        | R$ 400.00     | R$ 200.00 |
