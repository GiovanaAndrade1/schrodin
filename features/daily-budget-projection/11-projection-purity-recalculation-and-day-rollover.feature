Feature: Projection recalculation
  As a user
  I want the projection to reflect any change right away
  In order for it to always give the same result for the same data

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the daily amount is R$ 0.00 since 2026-01-01
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-12, planned
    And the expense "Rent" of R$ 600.00 in account "Nubank" on 2026-03-20, planned

  @PRJ-8
  Scenario Outline: Every change recalculates the projection
    Then the consolidated projected balance on 2026-03-15 is R$ 820.00
    And the consolidated projected balance on 2026-03-20 is R$ 220.00
    When I <change>
    Then the consolidated projected balance on 2026-03-15 is <today>
    And the consolidated projected balance on 2026-03-20 is <day 20>

    Examples:
      | change                                                                | today       | day 20    |
      | edit the expense "Rent" to R$ 700.00                                  | R$ 820.00   | R$ 120.00 |
      | delete the expense "Rent"                                             | R$ 820.00   | R$ 820.00 |
      | confirm the expense "Electricity" with amount R$ 203.40 on 2026-03-14 | R$ 796.60   | R$ 196.60 |
      | reschedule the expense "Electricity" to 2026-03-18                    | R$ 1,000.00 | R$ 220.00 |
      | change the daily amount to R$ 10.00 from 2026-03-15                   | R$ 810.00   | R$ 160.00 |

  @PRJ-8 @INV-1
  Scenario: The projection is pure and saves nothing
    When I compute the projection twice with the same data and today 2026-03-15
    Then both results are identical day by day
    And the actual balance of account "Nubank" is R$ 1,000.00
    And no entry is created

  @GER-3 @INV-6 @PRJ-1
  Scenario: Changing the time zone warns, may change "today" and changes no date
    Given the user's time zone is "America/Sao_Paulo"
    And the device clock reads 2026-03-16T03:30:00Z
    And the expense "Bakery" of R$ 20.00 in account "Nubank" on 2026-03-16, confirmed
    When I change the time zone to "America/Manaus"
    Then I see the confirmation prompt "Changing the time zone changes today's date. No entry date will be changed"
    When I confirm the time zone change
    Then today is 2026-03-15
    And I see the warning "1 confirmed entry now has tomorrow's date in the new time zone"
    And the expense "Bakery" is still on 2026-03-16 and "confirmed"
    And the projection starts on 2026-03-15
    And the consolidated projected balance on 2026-03-15 is R$ 800.00

  @GER-3 @STA-3 @STA-4 @DIA-5 @DIA-6 @PRJ-1
  Scenario Outline: The midnight rollover changes "today", releases yesterday's reserve and makes yesterday's planned entry overdue
    Given the daily amount changes to R$ 50.00 from 2026-03-15
    And the expense "Groceries" of R$ 100.00 in account "Nubank" on 2026-03-15, planned
    And confirmed daily spending totaling <spent> in account "Nubank" on 2026-03-15
    Then the consolidated projected balance on 2026-03-16 is <before>
    When the day turns to 2026-03-16
    Then the expense "Groceries" is "overdue"
    And there is no daily reserve on 2026-03-15
    And the consolidated projected balance on 2026-03-16 is <after>
    And the screen shows "surplus from yesterday's daily budget" of <surplus>

    Examples:
      | spent    | before    | after     | surplus  |
      | R$ 0.00  | R$ 620.00 | R$ 670.00 | R$ 50.00 |
      | R$ 30.00 | R$ 620.00 | R$ 640.00 | R$ 20.00 |
      | R$ 50.00 | R$ 620.00 | R$ 620.00 | R$ 0.00  |
      | R$ 80.00 | R$ 590.00 | R$ 590.00 | R$ 0.00  |
