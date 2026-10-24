Feature: Daily budget budgeted × spent
  As a user
  I want to compare what I budgeted with what I spent, per day and in the month
  In order to know whether I am overspending the daily budget

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01 and R$ 40.00 since 2026-03-10
    And the confirmed daily spending expenses:
      | title     | amount    | date       | where               |
      | Groceries | R$ 180.00 | 2026-03-02 | in account "Nubank" |
      | Bakery    | R$ 35.00  | 2026-03-05 | in account "Nubank" |
      | Uber      | R$ 45.00  | 2026-03-10 | on card "Purple"    |
      | Market    | R$ 440.00 | 2026-03-14 | in account "Nubank" |
      | Coffee    | R$ 20.00  | 2026-03-15 | in account "Nubank" |
    And the expense "Big Market" of R$ 60.00 in account "Nubank" on 2026-03-20, planned
    And the expense "Big Market" is daily spending
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-05, confirmed

  @DIA-9 @DIA-2
  Scenario: Budgeted and spent per day use the amount in effect on each day
    Then the daily budget per day shows:
      | date       | budgeted | spent     | surplus/overspend |
      | 2026-03-02 | R$ 50.00 | R$ 180.00 | -R$ 130.00        |
      | 2026-03-09 | R$ 50.00 | R$ 0.00   | R$ 50.00          |
      | 2026-03-10 | R$ 40.00 | R$ 45.00  | -R$ 5.00          |
      | 2026-03-14 | R$ 40.00 | R$ 440.00 | -R$ 400.00        |
      | 2026-03-15 | R$ 40.00 | R$ 20.00  | R$ 20.00          |

  @DIA-9
  Scenario: The month-to-date cumulative shows overspend
    Then the daily budget from 2026-03 to 2026-03-15 has budgeted R$ 690.00, spent R$ 720.00 and overspend R$ 30.00
    And the daily budget from 2026-03 to 2026-03-09 has budgeted R$ 450.00, spent R$ 215.00 and surplus R$ 235.00

  @DIA-9 @edge
  Scenario: Spent in budgeted × spent only counts confirmed daily spending
    Then the daily spending on 2026-03-20 is R$ 0.00
    And the daily spending on 2026-03-05 is R$ 35.00

  @DIA-9 @EST-3
  Scenario: A refund of a daily spending purchase reduces spent on the day of the refund
    Given the refund "Uber" of R$ 45.00 on card "Purple" on 2026-03-12 linked to the purchase "Uber"
    Then the daily spending on 2026-03-12 is -R$ 45.00
    And the daily budget from 2026-03 to 2026-03-15 has budgeted R$ 690.00, spent R$ 675.00 and surplus R$ 15.00

  @DIA-9 @EST-7
  Scenario: An account refund of daily spending reduces spent on the day of the account refund
    Given the account refund "Market" of R$ 40.00 in account "Nubank" on 2026-03-15 linked to the expense "Market"
    Then the daily spending on 2026-03-15 is -R$ 20.00
    And the daily spending on 2026-03-14 is R$ 440.00
    And the daily budget from 2026-03 to 2026-03-15 has budgeted R$ 690.00, spent R$ 680.00 and surplus R$ 10.00
