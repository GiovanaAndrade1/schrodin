Feature: Archiving an account by resolving the pending items

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 120.00 on 2026-01-01
    And "Nubank" is the default account
    And the daily budget source is account "Wallet"
    And the daily amount is R$ 50.00 since 2026-01-01
    And the projection horizon is 1 month
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Wallet" and start date 2026-01-01
    And the purchase "Dinner" of R$ 300.00 on card "Black" on 2026-03-10
    And the expense "Market" of R$ 40.00 in account "Wallet" on 2026-03-10, planned
    And the expense "Gift" of R$ 60.00 in account "Wallet" on 2026-03-28, planned
    And the recurring transfer "Allowance" of R$ 100.00 from account "Nubank" to account "Wallet", monthly, starting 2026-03-20, with no end

  @integration @CON-9 @CON-10 @CON-13 @CAR-3 @DIA-10 @REC-11 @TRF-4 @TRF-7 @FAT-6 @STA-4 @PRJ-5 @PRJ-7 @GER-5
  Scenario: Resolving each pending item and archiving without touching the consolidated balance beyond what was deleted
    Then the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 2,030.00 |
      | 2026-03-28 | R$ 1,320.00 |
      | 2026-04-05 | R$ 620.00   |
      | 2026-04-15 | R$ 120.00   |
    And the lowest future balance is R$ 120.00 on 2026-04-15
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                        | offered action                   |
      | Balance of R$ 120.00                | Transfer the balance             |
      | Overdue "Market" on 2026-03-10      | Move or delete the planned entry |
      | Planned "Gift" on 2026-03-28        | Move or delete the planned entry |
      | Recurring series "Allowance" active | End the series                   |
      | Pays card "Black"                   | Change the card's account        |
      | It is the daily budget source       | Change the daily budget source   |
    When I move the expense "Market" to account "Nubank"
    And I delete the expense "Gift"
    And I end the series "Allowance"
    And I switch the payment account of card "Black" to "Nubank"
    And I switch the daily budget source to the default account
    And I transfer the balance of R$ 120.00 from account "Wallet" to account "Nubank" on 2026-03-15
    And I archive the account "Wallet"
    Then the account "Wallet" is archived and read-only
    And the actual balance of account "Nubank" is R$ 2,120.00
    And the expense "Market" is "overdue" in account "Nubank"
    And the derived outflow of the 2026-04 statement of card "Black" is R$ 300.00 on 2026-04-05
    And the realized Saved for 2026-03 is R$ 0.00
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 2,030.00 |
      | 2026-03-28 | R$ 1,380.00 |
      | 2026-04-05 | R$ 680.00   |
      | 2026-04-15 | R$ 180.00   |
    And the lowest future balance is R$ 180.00 on 2026-04-15
    And the account "Wallet" is still in the history and in the reports for 2026-03

  @integration @CON-9 @TRF-4 @TRF-7 @IND-1 @IND-5 @IND-6 @IND-7
  Scenario: Archiving Reserve by taking its money out is a withdrawal
    Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And the income "Salary" of R$ 4,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the transfer "Save" of R$ 1,000.00 from account "Nubank" to account "Reserve" on 2026-03-06, confirmed
    And the realized Saved for 2026-03 is R$ 1,000.00
    When I transfer the balance of R$ 6,000.00 from account "Reserve" to account "Nubank" on 2026-03-15 through the archive flow
    And I archive the account "Reserve"
    Then the account "Reserve" is archived
    And the consolidated actual balance is R$ 11,120.00
    And the realized Saved for 2026-03 is -R$ 5,000.00
    And the realized savings rate for 2026-03 is -125.0%
    And the realized Inflows for 2026-03 are still R$ 4,000.00
