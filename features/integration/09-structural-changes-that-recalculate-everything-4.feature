Feature: Changing the opening balance

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-02-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-02-01
    And the daily amount is R$ 0.00 since 2026-02-01
    And the projection horizon is 1 month
    And the expense "Groceries" of R$ 100.00 in account "Nubank" on 2026-02-20, confirmed
    And the purchase "Pharmacy" of R$ 150.00 on card "Purple" on 2026-02-15
    And the payment of R$ 150.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the expense "Rent" of R$ 1,200.00 in account "Nubank" on 2026-03-20, planned
    And the income "Salary" of R$ 3,000.00 in account "Nubank" on 2026-04-05, planned

  @integration @CON-7 @CON-4 @PRJ-1 @PRJ-7 @TER-2 @IND-1 @IND-2 @INV-1
  Scenario: Changing the opening balance amount shifts actual balance, projection, highlights and colors, and no indicator
    Then the actual balance of account "Nubank" is R$ 750.00
    And the consolidated projected balance is:
      | date       | balance     | color      |
      | 2026-03-15 | R$ 750.00   | yellow     |
      | 2026-03-20 | -R$ 450.00  | pink       |
      | 2026-04-05 | R$ 2,550.00 | dark green |
    And the lowest future balance is -R$ 450.00 on 2026-03-20
    And the first negative day is 2026-03-20
    When I change the opening balance of account "Nubank" to R$ 1,500.00
    Then the actual balance of account "Nubank" is R$ 1,250.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-15 | R$ 1,250.00 | light green |
      | 2026-03-20 | R$ 50.00    | yellow      |
      | 2026-04-05 | R$ 3,050.00 | dark green  |
    And the lowest future balance is R$ 50.00 on 2026-03-20
    And there is no negative day
    And the realized Outflows for 2026-02 are still R$ 250.00
    And the realized Inflows for 2026-02 and for 2026-03 are still R$ 0.00

  @integration @CON-7 @CON-3 @FAT-7 @TRF-6 @INV-7 @error
  Scenario Outline: Postponing the opening date lists conflicts of every entry type
    When I change the opening date of account "Nubank" to <date>
    Then <result>

    Examples:
      | date       | result                                                                                                                  |
      | 2026-01-15 | the actual balance of account "Nubank" is still R$ 750.00                                                               |
      | 2026-02-20 | the actual balance of account "Nubank" is still R$ 750.00                                                               |
      | 2026-02-21 | the operation is blocked listing "Groceries (2026-02-20)"                                                               |
      | 2026-03-11 | the operation is blocked listing "Groceries (2026-02-20)" and "Payment of the 2026-03 statement of Purple (2026-03-10)" |
