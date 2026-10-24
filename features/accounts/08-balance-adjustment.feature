Feature: Balance adjustment

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And "Nubank" is the default account
    And the daily amount is R$ 0.00 since 2026-01-01

  @AJU-1
  Scenario: The bank shows more than the app: inflow adjustment
    When I adjust the balance of account "Nubank" to R$ 1,050.00
    Then there is an inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 1,050.00

  @AJU-1 @GER-4
  Scenario: The bank shows less than the app: outflow adjustment with a positive amount
    When I adjust the balance of account "Nubank" to R$ 950.00
    Then there is an outflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 950.00

  @AJU-1 @edge
  Scenario: Negative bank balance with a positive app balance
    Given the expense "Rent" of R$ 800.00 in account "Nubank" on 2026-03-05, confirmed
    When I adjust the balance of account "Nubank" to -R$ 150.00
    Then there is an outflow adjustment of R$ 350.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is -R$ 150.00

  @AJU-2 @edge
  Scenario: A zero difference creates nothing
    When I adjust the balance of account "Nubank" to R$ 1,000.00
    Then there is no adjustment in account "Nubank"
    And I see the warning "The balance already matches"

  @AJU-1 @edge
  Scenario: Two adjustments on the same day compare against the already adjusted actual balance
    When I adjust the balance of account "Nubank" to R$ 1,050.00
    And I adjust the balance of account "Nubank" to R$ 1,040.00
    Then there is an inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed
    And there is an outflow adjustment of R$ 10.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 1,040.00

  @AJU-1 @CON-4
  Scenario: An adjustment compares against the actual balance and ignores future planned entries
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-20, planned
    When I adjust the balance of account "Nubank" to R$ 990.00
    Then there is an outflow adjustment of R$ 10.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Electricity" is "planned"

  @AJU-1 @CON-3 @edge
  Scenario: An adjustment on the same day as the opening balance is allowed
    Given the account "Itaú" of kind "checking" with opening balance R$ 200.00 on 2026-03-15
    When I adjust the balance of account "Itaú" to R$ 210.00
    Then there is an inflow adjustment of R$ 10.00 in account "Itaú" on 2026-03-15, confirmed

  @AJU-1 @GER-8 @edge
  Scenario: Adjustment at the maximum amount
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    When I adjust the balance of account "Itaú" to R$ 99,999,999.99
    Then there is an inflow adjustment of R$ 99,999,999.99 in account "Itaú" on 2026-03-15, confirmed

  @AJU-1 @GER-8 @error @edge
  Scenario: A difference one cent above the maximum is blocked
    Given the account "Itaú" of kind "checking" with opening balance -R$ 0.01 on 2026-03-01
    When I adjust the balance of account "Itaú" to R$ 99,999,999.99
    Then the operation is blocked with the message "The maximum amount is R$ 99,999,999.99"
    And there is no adjustment in account "Itaú"

  @AJU-3
  Scenario: An account with an overdue entry warns before adjusting
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I adjust the balance of account "Nubank" to R$ 820.00
    Then I see the warning "Maybe you haven't confirmed: Electricity (R$ 180.00 on 2026-03-10)"
    And there is no adjustment in account "Nubank" yet

  @AJU-3 @CON-4
  Scenario: Confirming the overdue entry from the warning makes the adjustment unnecessary
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I adjust the balance of account "Nubank" to R$ 820.00
    And I choose to confirm the expense "Electricity" in the warning
    Then the expense "Electricity" is "confirmed"
    And the actual balance of account "Nubank" is R$ 820.00
    And there is no adjustment in account "Nubank"

  @AJU-3
  Scenario: Proceed with the adjustment despite the warning
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-10, planned
    When I adjust the balance of account "Nubank" to R$ 820.00
    And I choose "Adjust anyway" in the warning
    Then there is an outflow adjustment of R$ 180.00 in account "Nubank" on 2026-03-15, confirmed
    And the expense "Electricity" is "overdue"

  @AJU-3 @edge
  Scenario: A planned entry for today also triggers the warning
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-15, planned
    When I adjust the balance of account "Nubank" to R$ 6,000.00
    Then I see the warning "Maybe you haven't confirmed: Salary (R$ 5,000.00 on 2026-03-15)"
    And there is no adjustment in account "Nubank" yet

  @AJU-3 @edge
  Scenario: Only future planned entries do not trigger the warning
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-16, planned
    When I adjust the balance of account "Nubank" to R$ 1,020.00
    Then I do not see an overdue warning
    And there is an inflow adjustment of R$ 20.00 in account "Nubank" on 2026-03-15, confirmed

  @AJU-3 @FAT-9 @edge
  Scenario: An overdue statement paid by this account also triggers the warning
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-02-10
    And the 2026-03 statement of card "Purple" is "overdue"
    When I adjust the balance of account "Nubank" to R$ 700.00
    Then I see the warning "Maybe you haven't recorded the payment of the 2026-03 statement of card Purple (R$ 300.00)"

  @AJU-4 @IND-1 @IND-2 @IND-5 @IND-6
  Scenario: Adjustments do not count in any indicator
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-06, confirmed
    And the inflow adjustment of R$ 200.00 in account "Nubank" on 2026-03-10
    And the outflow adjustment of R$ 80.00 in account "Nubank" on 2026-03-12
    Then the realized Inflows for 2026-03 are R$ 5,000.00
    And the realized Outflows for 2026-03 are R$ 1,500.00
    And the realized Daily spending for 2026-03 is R$ 0.00
    And the realized Performance for 2026-03 is R$ 3,500.00
    And the realized Saved for 2026-03 is R$ 0.00
    And the actual balance of account "Nubank" is R$ 4,620.00

  @AJU-4 @TAG-10
  Scenario: An adjustment stays out of the tag report
    Given the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-06, confirmed
    And the outflow adjustment of R$ 80.00 in account "Nubank" on 2026-03-12
    Then the realized tag report for 2026-03 shows:
      | tag      | expenses    | income  |
      | Untagged | R$ 1,500.00 | R$ 0.00 |

  @AJU-4 @IND-8
  Scenario: An adjustment does not count in the cost of living
    Given the account "Itaú" of kind "checking" with opening balance R$ 10,000.00 on 2025-12-01
    And the expense "December Spending" of R$ 3,000.00 in account "Itaú" on 2025-12-10, confirmed
    And the expense "January Spending" of R$ 2,400.00 in account "Itaú" on 2026-01-10, confirmed
    And the expense "February Spending" of R$ 2,700.00 in account "Itaú" on 2026-02-10, confirmed
    And the outflow adjustment of R$ 500.00 in account "Itaú" on 2026-02-20
    Then the cost of living is R$ 2,700.00

  @AJU-4 @IND-6 @IND-12
  Scenario: An adjustment in a saving account does not become Saved
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-05, confirmed
    And the inflow adjustment of R$ 100.00 in account "Reserve" on 2026-03-10
    Then the realized Saved for 2026-03 is R$ 500.00
    And the actual balance of account "Reserve" is R$ 600.00

  @AJU-4 @PRJ-1 @PRJ-5
  Scenario: An adjustment counts in the consolidated balance and projection
    When I adjust the balance of account "Nubank" to R$ 1,050.00
    Then the consolidated projected balance on 2026-03-15 is R$ 1,050.00
    And the consolidated projected balance on 2026-04-15 is R$ 1,050.00

  @AJU-5 @CON-4
  Scenario: Deleting an adjustment restores the previous balance
    Given the inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15
    And the actual balance of account "Nubank" is R$ 1,050.00
    When I delete the adjustment of R$ 50.00 from account "Nubank"
    Then the actual balance of account "Nubank" is R$ 1,000.00

  @AJU-5 @AJU-4 @LAN-8 @error
  Scenario Outline: An adjustment cannot be edited beyond the note
    Given the inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15
    When I try to <edit> on the adjustment
    Then the operation is blocked with the message "<message>"
    And there is an inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed

    Examples:
      | edit                            | message                                                   |
      | change the amount to R$ 60.00   | An adjustment can't be edited. Delete it and adjust again |
      | change the date to 2026-03-14   | An adjustment can't be edited. Delete it and adjust again |
      | switch the type to "income"     | An adjustment can't be edited. Delete it and adjust again |
      | switch the type to "expense"    | An adjustment can't be edited. Delete it and adjust again |
      | switch the account to "Reserve" | An adjustment can't be edited. Delete it and adjust again |
      | unconfirm                       | An adjustment can't be edited. Delete it and adjust again |
      | add the tag "groceries"         | An adjustment has no tags                                 |

  @AJU-5 @GER-13
  Scenario: The adjustment note can be edited
    Given the outflow adjustment of R$ 7.90 in account "Nubank" on 2026-03-15
    When I change the adjustment note to "  missing   fee  "
    Then the adjustment note is "missing fee"
    And there is an outflow adjustment of R$ 7.90 in account "Nubank" on 2026-03-15, confirmed

  @AJU-5 @GER-13 @error @edge
  Scenario Outline: 1,000-character limit on the adjustment note
    Given the outflow adjustment of R$ 7.90 in account "Nubank" on 2026-03-15
    When I change the adjustment note to a text of <length> characters
    Then <result>

    Examples:
      | length | result                                                                                 |
      | 1000   | the adjustment note has 1000 characters                                                |
      | 1001   | the operation is blocked with the message "The note can have at most 1,000 characters" |

  @AJU-5 @GER-5
  Scenario: Undoing the adjustment deletion within 5 seconds restores the same entry
    Given the inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15
    When I delete the adjustment of R$ 50.00 from account "Nubank"
    And I tap "Undo" after 4 seconds
    Then there is an inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed
    And the adjustment has the same id and the same createdAt as before
    And the actual balance of account "Nubank" is R$ 1,050.00

  @AJU-5 @GER-5 @edge
  Scenario: After 5 seconds the adjustment deletion can no longer be undone
    Given the inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15
    When I delete the adjustment of R$ 50.00 from account "Nubank"
    And 5 seconds pass
    Then I do not see the option "Undo"
    And the actual balance of account "Nubank" is R$ 1,000.00
