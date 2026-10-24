Feature: "Can I buy it?" and the entry born from the simulation
  Converting a simulation has to produce exactly the "after" projection that the simulation showed.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-01
    And the daily amount is R$ 50.00 since 2026-03-01
    And the projection horizon is 1 month
    And the tag "groceries" that marks daily spending
    And the expense "Rent" of R$ 1,000.00 in account "Nubank" on 2026-03-20, planned
    And the income "Salary" of R$ 3,000.00 in account "Nubank" on 2026-04-05, planned

  @integration @SIM-1 @SIM-2 @SIM-5 @PRJ-7 @TER-2 @STA-2 @IND-2
  Scenario: Single-payment purchase in the account: simulate, convert and check that the projection is the simulated one
    Then the consolidated projected balance on 2026-04-03 is R$ 0.00
    And the lowest future balance is -R$ 50.00 on 2026-04-04
    And the first negative day is 2026-04-04
    When I simulate a purchase of R$ 300.00 in account "Nubank" on 2026-03-15
    Then the simulation shows the lowest future balance of -R$ 50.00 on 2026-04-04 without the purchase
    And the simulation shows the lowest future balance of -R$ 350.00 on 2026-04-04 with the purchase
    And the simulation shows the first negative day 2026-04-04 without the purchase
    And the simulation shows the first negative day 2026-03-29 with the purchase
    And the actual balance of account "Nubank" is R$ 2,000.00
    When I turn the simulation into an entry titled "Headphones"
    Then there is the expense "Headphones" of R$ 300.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 1,700.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-15 | R$ 1,650.00 | light green |
      | 2026-03-20 | R$ 400.00   | yellow      |
      | 2026-03-28 | R$ 0.00     | yellow      |
      | 2026-03-29 | -R$ 50.00   | pink        |
      | 2026-04-04 | -R$ 350.00  | pink        |
      | 2026-04-05 | R$ 2,600.00 | dark green  |
      | 2026-04-15 | R$ 2,100.00 | dark green  |
    And the lowest future balance is -R$ 350.00 on 2026-04-04
    And the first negative day is 2026-03-29
    And the realized Outflows for 2026-03 are R$ 300.00

  @integration @SIM-1 @SIM-2 @SIM-3 @SIM-5 @PAR-1 @PAR-6 @LIM-1 @FAT-6 @IND-2 @IND-11
  Scenario: Installments on the card: only the April installment fits in the horizon
    When I simulate a purchase of R$ 1,200.00 on card "Purple" on 2026-03-15 in 3 installments
    Then the simulation shows the installments of R$ 400.00 in the statements of 2026-04, 2026-05 and 2026-06
    And the simulation compares against the available limit of R$ 5,000.00, with no warning
    And the simulation shows the lowest future balance of -R$ 50.00 on 2026-04-04 without the purchase
    And the simulation shows the lowest future balance of -R$ 50.00 on 2026-04-04 with the purchase
    And the simulation shows the consolidated balance of R$ 2,650.00 on 2026-04-10 without the purchase
    And the simulation shows the consolidated balance of R$ 2,250.00 on 2026-04-10 with the purchase
    When I turn the simulation into an entry titled "Bicycle"
    Then there is the purchase "Bicycle" of R$ 1,200.00 on card "Purple" on 2026-03-15 in 3 installments, confirmed
    And the available limit of card "Purple" is R$ 3,800.00
    And the consolidated projected balance on 2026-04-10 is R$ 2,250.00
    And the consolidated projected balance on 2026-04-15 is R$ 2,000.00
    And the realized Outflows for 2026-03 are R$ 400.00
    And the forecast Outflows for 2026-04 are R$ 400.00
    And the forecast Outflows for 2026-05 are R$ 400.00

  @integration @SIM-4 @SIM-5 @DIA-5 @LAN-6 @PRJ-7
  Scenario Outline: A daily spending simulation uses today's reserve before touching the balance
    When I simulate a daily spending purchase of <amount> in account "Nubank" on 2026-03-15
    Then the simulation shows the daily reserve on 2026-03-15 of <reserve> with the purchase
    And the simulation shows the consolidated balance of <today> on 2026-03-15 with the purchase
    And the simulation shows the lowest future balance of <lowest> on 2026-04-04 with the purchase
    And the simulation shows the first negative day <negative> with the purchase
    When I turn the simulation into an entry titled "Groceries"
    Then the expense "Groceries" is daily spending
    And the consolidated projected balance on 2026-03-15 is <today>
    And the lowest future balance is <lowest> on 2026-04-04

    Examples:
      | amount   | reserve  | today       | lowest    | negative   |
      | R$ 30.00 | R$ 20.00 | R$ 1,950.00 | -R$ 50.00 | 2026-04-04 |
      | R$ 50.00 | R$ 0.00  | R$ 1,950.00 | -R$ 50.00 | 2026-04-04 |
      | R$ 80.00 | R$ 0.00  | R$ 1,920.00 | -R$ 80.00 | 2026-04-03 |

  @integration @SIM-1 @SIM-5 @GER-3 @STA-2 @DIA-6
  Scenario: Midnight passes between simulating and converting
    When I simulate a purchase of R$ 300.00 in account "Nubank" on 2026-03-15
    And the day turns to 2026-03-16
    And I turn the simulation into an entry titled "Headphones"
    Then I see the warning "The simulated date (2026-03-15) has passed. Keep it or use today?"
    When I choose to keep
    Then there is the expense "Headphones" of R$ 300.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 1,700.00
    And the consolidated projected balance on 2026-03-16 is R$ 1,650.00

  @integration @SIM-3 @SIM-5 @LIM-2 @LIM-3 @STA-6 @FAT-6
  Scenario: A future card simulation uses the available limit after planned entries, and the purchase confirms itself
    Given the purchase "Ticket" of R$ 4,500.00 on card "Purple" on 2026-03-25
    Then the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Purple" after planned entries is R$ 500.00
    When I simulate a purchase of R$ 800.00 on card "Purple" on 2026-03-28
    Then I see the warning "This purchase exceeds the available limit after planned entries (R$ 500.00) by R$ 300.00"
    When I turn the simulation into an entry titled "Hotel"
    Then the purchase "Hotel" is "planned" in the 2026-04 statement of card "Purple"
    And I see the warning "This purchase exceeds the available limit after planned entries (R$ 500.00) by R$ 300.00"
    And the available limit of card "Purple" is R$ 5,000.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 5,300.00 on 2026-04-10
    When the day turns to 2026-03-25
    Then the purchase "Ticket" is "confirmed"
    And the available limit of card "Purple" is R$ 500.00
    And the derived outflow of the 2026-04 statement of card "Purple" is still R$ 5,300.00
    When the day turns to 2026-03-28
    Then the purchase "Hotel" is "confirmed"
    And the available limit of card "Purple" is -R$ 300.00, with a warning
    And the derived outflow of the 2026-04 statement of card "Purple" is still R$ 5,300.00
