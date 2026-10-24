Feature: Simulation "can I buy it?"
  As a user
  I want to see the effect of a purchase before making it
  In order to decide without messing up my data

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,500.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 3 months
    And the purchase "Groceries" of R$ 200.00 on card "Purple" on 2026-03-05
    And the expense "Rent" of R$ 1,000.00 in account "Nubank" on 2026-03-20, planned
    And the income "Salary" of R$ 3,000.00 in account "Nubank" on 2026-04-01, planned

  @PRJ-7 @edge
  Scenario: Base projection of the simulation (tie for the lowest balance)
    Then the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 1,500.00 |
      | 2026-03-20 | R$ 500.00   |
      | 2026-03-31 | R$ 500.00   |
      | 2026-04-01 | R$ 3,500.00 |
      | 2026-04-10 | R$ 3,300.00 |
      | 2026-06-15 | R$ 3,300.00 |
    And the lowest future balance is R$ 500.00 on 2026-03-20
    And there is no negative day
    And the available limit of card "Purple" is R$ 4,800.00

  @SIM-1 @SIM-2
  Scenario: A single-payment purchase in the account that makes the balance negative
    When I simulate a purchase of R$ 800.00 in account "Nubank" on 2026-03-18
    Then the simulation shows the lowest future balance of R$ 500.00 on 2026-03-20 without the purchase
    And the simulation shows the lowest future balance of -R$ 300.00 on 2026-03-20 with the purchase
    And the simulation shows the consolidated balance of R$ 700.00 on 2026-03-18 with the purchase
    And the simulation shows the first negative day 2026-03-20 with the purchase
    And the simulation shows that there is no negative day without the purchase

  @SIM-1 @SIM-2 @PAR-1
  Scenario: An installment purchase in the account creates monthly planned entries
    When I simulate a purchase of R$ 900.00 in account "Nubank" on 2026-03-25 in 3 installments
    Then the simulation shows the consolidated balance with the purchase:
      | date       | balance     |
      | 2026-03-25 | R$ 200.00   |
      | 2026-04-10 | R$ 3,000.00 |
      | 2026-04-25 | R$ 2,700.00 |
      | 2026-05-25 | R$ 2,400.00 |
    And the simulation shows the lowest future balance of R$ 200.00 on 2026-03-25 with the purchase

  @SIM-3 @PAR-2 @PRJ-6 @LIM-1
  Scenario: An installment purchase on a card falls into different statements
    When I simulate a purchase of R$ 1,000.00 on card "Purple" on 2026-03-15 in 3 installments
    Then the simulation shows the installments:
      | k | amount    | statement | due date   |
      | 1 | R$ 333.34 | 2026-04   | 2026-04-10 |
      | 2 | R$ 333.33 | 2026-05   | 2026-05-10 |
      | 3 | R$ 333.33 | 2026-06   | 2026-06-10 |
    And the simulation shows the consolidated balance with the purchase:
      | date       | balance     |
      | 2026-04-09 | R$ 3,500.00 |
      | 2026-04-10 | R$ 2,966.66 |
      | 2026-05-10 | R$ 2,633.33 |
      | 2026-06-10 | R$ 2,300.00 |
    And the simulation shows the available limit of R$ 3,800.00 after the purchase
    And the simulation shows no limit warning
    And the simulation shows the lowest future balance of R$ 500.00 on 2026-03-20 with the purchase

  @SIM-3 @LIM-2 @edge
  Scenario: A card purchase above the available limit warns, but simulates
    When I simulate a purchase of R$ 5,000.00 on card "Purple" on 2026-03-15
    Then I see the warning "This purchase exceeds the available limit (R$ 4,800.00) by R$ 200.00"
    And the simulation shows the consolidated balance of -R$ 1,700.00 on 2026-04-10 with the purchase
    And the simulation shows the lowest future balance of -R$ 1,700.00 on 2026-04-10 with the purchase
    And the simulation shows the first negative day 2026-04-10 with the purchase

  @SIM-3 @LIM-2 @edge
  Scenario: A purchase exactly at the available limit does not warn
    When I simulate a purchase of R$ 4,800.00 on card "Purple" on 2026-03-15
    Then the simulation shows no limit warning
    And the simulation shows the available limit of R$ 0.00 after the purchase

  @SIM-3 @FAT-1 @edge
  Scenario: A simulation on the closing day falls into the next statement
    When I simulate a purchase of R$ 300.00 on card "Purple" on 2026-04-03
    Then the simulation shows installment 1 in the 2026-05 statement due on 2026-05-10
    And the simulation shows the consolidated balance of R$ 3,300.00 on 2026-04-10 with the purchase
    And the simulation shows the consolidated balance of R$ 3,000.00 on 2026-05-10 with the purchase

  @SIM-3 @LIM-3 @LIM-2 @edge
  Scenario: A future simulation on a card compares against the available limit after planned entries
    Given the purchase "Concert" of R$ 1,000.00 on card "Purple" on 2026-03-25
    Then the available limit of card "Purple" is R$ 4,800.00
    When I simulate a purchase of R$ 3,900.00 on card "Purple" on 2026-03-28
    Then I see the warning "This purchase exceeds the available limit after planned entries (R$ 3,800.00) by R$ 100.00"

  @SIM-4 @DIA-5 @DIA-6
  Scenario Outline: A daily spending simulation consumes the day's reserve
    Given the daily amount changes to R$ 50.00 from 2026-03-15
    And the expense "Coffee" of R$ 20.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Coffee" is daily spending
    And the consolidated projected balance on 2026-03-15 is R$ 1,450.00
    When I simulate a purchase of <amount> in account "Nubank" on 2026-03-15 <flag>
    Then the simulation shows the daily reserve on 2026-03-15 of <reserve> with the purchase
    And the simulation shows the consolidated balance of <balance> on 2026-03-15 with the purchase

    Examples:
      | amount   | flag                  | reserve  | balance     |
      | R$ 25.00 | as daily spending     | R$ 5.00  | R$ 1,450.00 |
      | R$ 30.00 | as daily spending     | R$ 0.00  | R$ 1,450.00 |
      | R$ 45.00 | as daily spending     | R$ 0.00  | R$ 1,435.00 |
      | R$ 25.00 | not as daily spending | R$ 30.00 | R$ 1,425.00 |

  @SIM-1 @PRJ-8
  Scenario: Simulating and leaving saves nothing
    When I simulate a purchase of R$ 1,000.00 on card "Purple" on 2026-03-15 in 3 installments
    And I close the simulation
    Then no entry is created
    And the available limit of card "Purple" is R$ 4,800.00
    And the consolidated projected balance on 2026-04-10 is R$ 3,300.00
    And the 2026-04 statement of card "Purple" has total R$ 200.00 and outstanding R$ 200.00

  @SIM-5 @STA-2
  Scenario Outline: Turning an account simulation into a real entry
    When I simulate a purchase of R$ 800.00 in account "Nubank" on <date>
    And I turn the simulation into an entry titled "Fridge"
    Then the expense "Fridge" of R$ 800.00 in account "Nubank" on <date> is "<status>"
    And the consolidated projected balance on 2026-03-20 is <day 20>

    Examples:
      | date       | status    | day 20     |
      | 2026-03-18 | planned   | -R$ 300.00 |
      | 2026-03-15 | confirmed | -R$ 300.00 |

  @SIM-5 @PAR-1 @LIM-1 @STA-6
  Scenario: Turning an installment simulation on a card into a real purchase uses the limit
    When I simulate a purchase of R$ 1,000.00 on card "Purple" on 2026-03-15 in 3 installments
    And I turn the simulation into an entry titled "Phone"
    Then the purchase "Phone" is "confirmed"
    And the installments of the purchase "Phone" are:
      | k | amount    | statement |
      | 1 | R$ 333.34 | 2026-04   |
      | 2 | R$ 333.33 | 2026-05   |
      | 3 | R$ 333.33 | 2026-06   |
    And the available limit of card "Purple" is R$ 3,800.00

  @SIM-5 @SIM-4 @LAN-6
  Scenario: Turning a daily spending simulation keeps the daily spending flag
    Given the daily amount changes to R$ 50.00 from 2026-03-15
    When I simulate a purchase of R$ 25.00 in account "Nubank" on 2026-03-15 as daily spending
    And I turn the simulation into an entry titled "Lunch"
    Then the expense "Lunch" is daily spending
    And the daily reserve on 2026-03-15 is R$ 25.00

  @SIM-5 @GER-3 @STA-2 @edge
  Scenario: The simulated date became past after midnight: warns and offers today
    When I simulate a purchase of R$ 800.00 in account "Nubank" on 2026-03-15
    And the day turns to 2026-03-16
    And I turn the simulation into an entry titled "Fridge"
    Then I see the warning "The simulated date (2026-03-15) has passed. Use today (2026-03-16)?"
    When I accept using today
    Then the expense "Fridge" of R$ 800.00 in account "Nubank" on 2026-03-16 is "confirmed"
    And the consolidated projected balance on 2026-03-20 is -R$ 300.00

  @SIM-5 @STA-2 @CON-4 @edge
  Scenario: The simulated date became past: keeping the old date creates the entry confirmed on it
    When I simulate a purchase of R$ 800.00 in account "Nubank" on 2026-03-15
    And the day turns to 2026-03-16
    And I turn the simulation into an entry titled "Fridge"
    Then I see the warning "The simulated date (2026-03-15) has passed. Use today (2026-03-16)?"
    When I keep the simulated date
    Then the expense "Fridge" of R$ 800.00 in account "Nubank" on 2026-03-15 is "confirmed"
    And the actual balance of account "Nubank" is R$ 700.00
    And the consolidated projected balance on 2026-03-20 is -R$ 300.00

  @SIM-5 @LAN-1 @error
  Scenario: Turning it into an entry without a title is blocked and nothing is saved
    When I simulate a purchase of R$ 800.00 in account "Nubank" on 2026-03-18
    And I turn the simulation into an entry titled "   "
    Then the operation is blocked with the message "Title required"
    And no entry is created

  @SIM-5 @LAN-9 @error
  Scenario: An account archived between the simulation and the conversion blocks the entry
    When I simulate a purchase of R$ 50.00 in account "Wallet" on 2026-03-18
    And the account "Wallet" gets archived
    And I turn the simulation into an entry titled "Market"
    Then the operation is blocked with the message "Account 'Wallet' is archived. Unarchive it to make changes"
    And no entry is created

  @SIM-1 @error
  Scenario: Simulation in a saving account is not offered
    When I simulate a purchase of R$ 300.00 in account "Reserve" on 2026-03-18
    Then the operation is blocked with the message "Simulation only in a spending account or card"
    And no entry is created

  @SIM-1 @GER-12 @edge
  Scenario: A simulation on the last day of the horizon is accepted
    When I simulate a purchase of R$ 300.00 in account "Nubank" on 2026-06-15
    Then the simulation shows the consolidated balance of R$ 3,000.00 on 2026-06-15 with the purchase
    And the simulation shows the lowest future balance of R$ 500.00 on 2026-03-20 with the purchase

  @SIM-1 @LAN-1 @LAN-7 @PAR-1 @GER-8 @error
  Scenario Outline: A simulation with invalid data is rejected
    When I simulate a purchase of <amount> in account "Nubank" on <date> <form>
    Then the operation is blocked with the message "<message>"
    And no entry is created

    Examples:
      | amount            | date       | form               | message                                            |
      | R$ 0.00           | 2026-03-18 | single payment     | The amount must be greater than zero               |
      | R$ 100,000,000.00 | 2026-03-18 | single payment     | The amount exceeds the maximum of R$ 99,999,999.99 |
      | R$ 900.00         | 2026-03-18 | in 73 installments | The number of installments must be 2 to 72         |
      | R$ 900.00         | 2026-03-18 | in 1 installments  | The number of installments must be 2 to 72         |
      | R$ 900.00         | 2026-06-16 | single payment     | The date is beyond the projection horizon          |
      | R$ 900.00         | 2026-03-14 | single payment     | The simulation must be from today on               |
