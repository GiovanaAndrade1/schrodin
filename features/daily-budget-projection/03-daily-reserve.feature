Feature: Daily reserve
  As a user
  I want the projection to set aside what is left to spend of the daily budget on each day
  In order not to count twice what I already spent

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01

  @DIA-5 @DIA-7 @PRJ-2
  Scenario: Nothing spent today reserves the whole daily amount
    Then the daily reserve on 2026-03-15 is R$ 50.00
    And the consolidated projected balance on 2026-03-15 is R$ 950.00

  @DIA-5 @DIA-6 @DIA-8 @PRJ-2
  Scenario Outline: Today's daily spending consumes today's reserve
    Given the daily spending "Coffee" of <amount> <means> on 2026-03-15 <status>
    Then the daily reserve on 2026-03-15 is <reserve>
    And the consolidated projected balance on 2026-03-15 is <balance today>

    Examples:
      | amount   | means               | status    | reserve  | balance today |
      | R$ 30.00 | in account "Nubank" | confirmed | R$ 20.00 | R$ 950.00     |
      | R$ 30.00 | in account "Nubank" | planned   | R$ 20.00 | R$ 950.00     |
      | R$ 30.00 | in account "Wallet" | confirmed | R$ 20.00 | R$ 950.00     |
      | R$ 30.00 | on card "Purple"    | confirmed | R$ 20.00 | R$ 980.00     |
      | R$ 49.99 | in account "Nubank" | confirmed | R$ 0.01  | R$ 950.00     |
      | R$ 50.00 | in account "Nubank" | confirmed | R$ 0.00  | R$ 950.00     |
      | R$ 70.00 | in account "Nubank" | confirmed | R$ 0.00  | R$ 930.00     |

  @DIA-5 @DIA-6
  Scenario: Several daily spending expenses on the same day add up
    Given the expense "Coffee" of R$ 20.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Coffee" is daily spending
    And the purchase "Bread" of R$ 15.00 on card "Purple" on 2026-03-15
    And the purchase "Bread" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 15.00

  @DIA-6 @edge
  Scenario: One day's overspend is not deducted from the other days
    Given the expense "Market" of R$ 70.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Market" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 0.00
    And the daily reserve on 2026-03-16 is R$ 50.00
    And the consolidated projected balance on 2026-03-16 is R$ 880.00

  @DIA-5
  Scenario: An expense that is not daily spending does not consume the reserve
    Given the expense "Pharmacy" of R$ 30.00 in account "Nubank" on 2026-03-15, confirmed
    Then the daily reserve on 2026-03-15 is R$ 50.00
    And the consolidated projected balance on 2026-03-15 is R$ 920.00

  @DIA-5 @PRJ-3
  Scenario: A planned daily spending entry on a future day consumes that day's reserve
    Given the expense "Market" of R$ 30.00 in account "Nubank" on 2026-03-20, planned
    And the expense "Market" is daily spending
    Then the daily reserve on 2026-03-20 is R$ 20.00
    And the daily reserve on 2026-03-19 is R$ 50.00
    And the consolidated projected balance on 2026-03-19 is R$ 750.00
    And the consolidated projected balance on 2026-03-20 is R$ 700.00

  @DIA-5 @edge
  Scenario: A past day has no reserve
    Then there is no daily reserve on 2026-03-14
    And the consolidated projected balance on 2026-03-15 is R$ 950.00

  @DIA-5 @STA-4 @edge
  Scenario: An overdue planned daily spending entry counts today and does not consume today's reserve
    Given the expense "Market" of R$ 30.00 in account "Nubank" on 2026-03-14, planned
    And the expense "Market" is daily spending
    Then the expense "Market" is "overdue"
    And the daily reserve on 2026-03-15 is R$ 50.00
    And the consolidated projected balance on 2026-03-15 is R$ 920.00

  @DIA-5 @DIA-1 @edge
  Scenario: With a zero daily amount, daily spending does not create a negative reserve
    Given the daily amount changes to R$ 0.00 from 2026-03-15
    And the expense "Coffee" of R$ 30.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Coffee" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 0.00
    And the consolidated projected balance on 2026-03-15 is R$ 970.00

  @DIA-5 @EST-3 @edge
  Scenario: A refund of a daily spending purchase on the same day does not increase the reserve
    Given the purchase "Lunch" of R$ 40.00 on card "Purple" on 2026-03-15
    And the purchase "Lunch" is daily spending
    And the refund "Lunch" of R$ 40.00 on card "Purple" on 2026-03-15 linked to the purchase "Lunch"
    Then the daily reserve on 2026-03-15 is R$ 10.00

  @DIA-5 @EST-7 @edge
  Scenario: An account refund of daily spending on the same day does not increase the reserve
    Given the expense "Market" of R$ 40.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Market" is daily spending
    And the account refund "Market" of R$ 40.00 in account "Nubank" on 2026-03-15 linked to the expense "Market"
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the daily reserve on 2026-03-15 is R$ 10.00
    And the consolidated projected balance on 2026-03-15 is R$ 990.00

  @DIA-8 @PRJ-6
  Scenario: Daily spending on a card consumes the reserve and leaves the cash through the statement, without double counting
    Given the purchase "Lunch" of R$ 35.00 on card "Purple" on 2026-03-15
    And the purchase "Lunch" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 15.00
    And the purchase "Lunch" is in the 2026-04 statement of card "Purple"
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 985.00
    And the projected balance of account "Nubank" on 2026-03-16 is R$ 935.00
    And the projected balance of account "Nubank" on 2026-04-09 is -R$ 265.00
    And the projected balance of account "Nubank" on 2026-04-10 is -R$ 350.00

  @DIA-8 @STA-6 @LIM-3 @FAT-4 @FAT-5 @FAT-6
  Scenario: A future daily spending purchase on a card consumes the reserve of its day
    Given the purchase "Gift" of R$ 80.00 on card "Purple" on 2026-03-20
    And the purchase "Gift" is daily spending
    Then the purchase "Gift" is "planned"
    And the daily reserve on 2026-03-20 is R$ 0.00
    And the projected balance of account "Nubank" on 2026-03-20 is R$ 750.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and shows "+ R$ 80.00 planned"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 80.00 on 2026-04-10

  @DIA-4 @LAN-6 @error
  Scenario: An expense in a saving account cannot be daily spending
    When I add the expense "Fee" of R$ 10.00 to account "Reserve" on 2026-03-15
    And I flag the expense "Fee" as daily spending
    Then the operation is blocked with the message "An expense in a saving account can't be daily spending"
    And the daily reserve on 2026-03-15 is R$ 50.00

  @CON-12 @DIA-5 @PRJ-5
  Scenario: An account that becomes saving has the daily spending flag ignored, and it comes back if the account becomes spending again
    Given the expense "Market" of R$ 30.00 in account "Wallet" on 2026-03-15, confirmed
    And the expense "Market" is daily spending
    Then the daily reserve on 2026-03-15 is R$ 20.00
    When I change the purpose of account "Wallet" to "saving" and confirm the warning
    Then the daily reserve on 2026-03-15 is R$ 50.00
    And the consolidated projected balance on 2026-03-15 is R$ 950.00
    And the expense "Market" is still flagged as daily spending
    When I change the purpose of account "Wallet" to "spending" and confirm the warning
    Then the daily reserve on 2026-03-15 is R$ 20.00
    And the consolidated projected balance on 2026-03-15 is R$ 950.00
