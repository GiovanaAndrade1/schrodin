Feature: Daily amount suggestion
  As a user
  I want a suggestion based on what I actually spent
  In order to choose a realistic daily amount

  Background:
    Given today is 2026-03-15
    And the daily amount is R$ 50.00 since 2026-01-01

  @DIA-3 @edge
  Scenario Outline: The suggestion divides by min(days of use, 90) and only appears with 30 days or more
    Given the first account was created on <creation>
    And confirmed daily spending totaling R$ 1,350.00 between <start> and 2026-03-14
    Then the app counts <days> days of use
    And <result>

    Examples:
      | creation   | start      | days | result                                  |
      | 2026-03-14 | 2026-03-14 | 1    | there is no daily amount suggestion     |
      | 2026-02-14 | 2026-02-14 | 29   | there is no daily amount suggestion     |
      | 2026-02-13 | 2026-02-13 | 30   | the daily amount suggestion is R$ 45.00 |
      | 2026-01-29 | 2026-01-29 | 45   | the daily amount suggestion is R$ 30.00 |
      | 2025-12-16 | 2025-12-16 | 89   | the daily amount suggestion is R$ 15.17 |
      | 2025-12-15 | 2025-12-15 | 90   | the daily amount suggestion is R$ 15.00 |
      | 2025-11-15 | 2025-12-15 | 120  | the daily amount suggestion is R$ 15.00 |

  @DIA-3 @GER-6 @edge
  Scenario: Days of use count from the creation of the first account, not from the opening date
    Given the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2025-12-01
    And the first account was created on 2026-02-14
    And confirmed daily spending totaling R$ 1,350.00 between 2025-12-15 and 2026-03-14
    Then the app counts 29 days of use
    And there is no daily amount suggestion

  @DIA-3 @edge
  Scenario: 90 calendar-day window, included and excluded boundaries
    Given the first account was created on 2025-12-01
    And the account "Nubank" of kind "checking" with opening balance R$ 10,000.00 on 2025-12-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2025-12-01
    And the expenses in account "Nubank":
      | title     | amount      | date       | status    | daily spending |
      | Older     | R$ 900.00   | 2025-12-14 | confirmed | yes            |
      | Market    | R$ 1,000.00 | 2025-12-15 | confirmed | yes            |
      | Groceries | R$ 500.00   | 2026-03-14 | confirmed | yes            |
      | Today     | R$ 300.00   | 2026-03-15 | confirmed | yes            |
      | Forgotten | R$ 100.00   | 2026-03-10 | planned   | yes            |
      | Rent      | R$ 2,000.00 | 2026-03-05 | confirmed | no             |
    And the purchase "Restaurant" of R$ 1,000.00 on card "Purple" on 2026-03-01
    And the purchase "Restaurant" is daily spending
    Then the daily spending sum in the window from 2025-12-15 to 2026-03-14 is R$ 2,500.00
    And the daily amount suggestion is R$ 27.78

  @DIA-3 @EST-3 @EST-7
  Scenario: Refunds and account refunds of daily spending purchases in the window reduce the suggestion base
    Given the first account was created on 2025-12-01
    And the account "Nubank" of kind "checking" with opening balance R$ 10,000.00 on 2025-12-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2025-12-01
    And the purchase "Restaurant" of R$ 1,000.00 on card "Purple" on 2026-03-01
    And the purchase "Restaurant" is daily spending
    And the purchase "Concert" of R$ 400.00 on card "Purple" on 2026-03-02
    And the refund "Restaurant" of R$ 100.00 on card "Purple" on 2026-03-05 linked to the purchase "Restaurant"
    And the refund "Concert" of R$ 400.00 on card "Purple" on 2026-03-06 linked to the purchase "Concert"
    And the expense "Market" of R$ 200.00 in account "Nubank" on 2026-03-03, confirmed
    And the expense "Market" is daily spending
    And the account refund "Market" of R$ 50.00 in account "Nubank" on 2026-03-04 linked to the expense "Market"
    Then the daily spending sum in the window from 2025-12-15 to 2026-03-14 is R$ 1,050.00
    And the daily amount suggestion is R$ 11.67

  @DIA-3 @GER-10 @edge
  Scenario Outline: Suggestion rounding (half away from zero)
    Given the first account was created on 2025-12-01
    And confirmed daily spending totaling <total> between 2025-12-15 and 2026-03-14
    Then the daily amount suggestion is <suggestion>

    Examples:
      | total       | suggestion |
      | R$ 4,500.00 | R$ 50.00   |
      | R$ 2,500.00 | R$ 27.78   |
      | R$ 1,000.00 | R$ 11.11   |
      | R$ 5.00     | R$ 0.06    |
      | R$ 4.50     | R$ 0.05    |
      | R$ 0.45     | R$ 0.01    |
      | R$ 0.00     | R$ 0.00    |

  @DIA-3 @DIA-2
  Scenario: The suggestion does not change the daily amount until the user accepts it
    Given the first account was created on 2025-12-01
    And confirmed daily spending totaling R$ 2,500.00 between 2025-12-15 and 2026-03-14
    Then the daily amount suggestion is R$ 27.78
    And the daily amount in effect on 2026-03-15 is R$ 50.00
    When I accept the daily amount suggestion
    Then the daily amount in effect on 2026-03-15 is R$ 27.78
    And the daily amount in effect on 2026-03-14 is R$ 50.00
