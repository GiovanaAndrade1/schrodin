Feature: Account editing

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 0.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And "Nubank" is the default account
    And the daily amount is R$ 0.00 since 2026-01-01

  @CON-1 @GER-9 @error
  Scenario: Renaming to another active account's name is blocked
    When I rename the account "Wallet" to "NUBANK"
    Then the operation is blocked with the message "An active account with this name already exists"
    And there is the active account "Wallet"

  @CON-1 @GER-9 @edge
  Scenario: Renaming an account to itself changing only case or accents is allowed
    When I rename the account "Nubank" to "NuBank"
    Then there is the active account "NuBank"

  @CON-7 @CON-4 @PRJ-8
  Scenario: Changing the opening balance amount recalculates the actual balance and the projection
    Given the income "Salary" of R$ 500.00 in account "Nubank" on 2026-02-05, confirmed
    And the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-10, confirmed
    And the actual balance of account "Nubank" is R$ 1,380.00
    When I change the opening balance of account "Nubank" to R$ 1,200.00
    Then the actual balance of account "Nubank" is R$ 1,580.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 1,580.00

  @CON-7
  Scenario: Moving the opening date earlier is allowed
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-01-10, confirmed
    When I change the opening date of account "Nubank" to 2025-12-01
    Then the opening date of account "Nubank" is 2025-12-01
    And the actual balance of account "Nubank" is R$ 880.00

  @CON-7 @CON-3 @error
  Scenario: Moving the opening date after entries is blocked and lists the conflicts
    Given the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-01-10, confirmed
    And the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-02-05, confirmed
    And the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-10, confirmed
    When I change the opening date of account "Nubank" to 2026-02-06
    Then the operation is blocked with the message "There are entries before the new opening date"
    And I see the conflicting entries:
      | entry  | date       |
      | Rent   | 2026-01-10 |
      | Salary | 2026-02-05 |
    And the opening date of account "Nubank" is 2026-01-01

  @CON-7 @CON-3 @edge
  Scenario: Moving the opening date to the day of the oldest entry is allowed
    Given the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-01-10, confirmed
    When I change the opening date of account "Nubank" to 2026-01-10
    Then the opening date of account "Nubank" is 2026-01-10
    And the actual balance of account "Nubank" is -R$ 500.00

  @CON-7 @CON-3 @STA-3 @error @edge
  Scenario: An overdue planned entry also counts as a conflict
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-01, planned
    When I change the opening date of account "Nubank" to 2026-03-05
    Then the operation is blocked with the message "There are entries before the new opening date"
    And I see the conflicting entries:
      | entry       | date       |
      | Electricity | 2026-03-01 |

  @CON-7 @CON-3 @TRF-6 @error
  Scenario: A received transfer counts as a conflict in the destination account
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-02-10, confirmed
    When I change the opening date of account "Reserve" to 2026-02-11
    Then the operation is blocked with the message "There are entries before the new opening date"
    And I see the conflicting entries:
      | entry | date       |
      | Save  | 2026-02-10 |

  @CON-7 @CON-3 @AJU-1 @error
  Scenario: An old adjustment also counts as a conflict
    Given the outflow adjustment of R$ 30.00 in account "Nubank" on 2026-03-10
    When I change the opening date of account "Nubank" to 2026-03-12
    Then the operation is blocked with the message "There are entries before the new opening date"
    And I see the conflicting entries:
      | entry      | date       |
      | Adjustment | 2026-03-10 |

  @CON-7 @CON-2 @error
  Scenario: Moving the opening date to the future is blocked
    When I change the opening date of account "Nubank" to 2026-03-16
    Then the operation is blocked with the message "The opening date can't be in the future"

  @CON-6 @edge
  Scenario: Changing the kind does not change the purpose
    When I change the kind of account "Wallet" to "savings"
    Then the account "Wallet" has purpose "spending"

  @CON-12
  Scenario: Changing the purpose warns before recalculating
    When I change the purpose of account "Wallet" to "saving"
    Then I see the warning "Changing the purpose recalculates the indicators for this account's entire history"

  @CON-12
  Scenario: Cancelling the warning keeps the purpose
    When I change the purpose of account "Wallet" to "saving"
    And I cancel the warning
    Then the account "Wallet" has purpose "spending"

  @CON-12 @CON-6 @IND-2 @IND-12
  Scenario: A spending account turned saving leaves the past indicators
    Given the expense "Market" of R$ 80.00 in account "Wallet" on 2026-02-10, confirmed
    And the realized Outflows for 2026-02 are R$ 80.00
    When I change the purpose of account "Wallet" to "saving"
    And I confirm the warning
    Then the realized Outflows for 2026-02 are R$ 0.00

  @CON-12 @IND-6 @TRF-4
  Scenario: A saving account turned spending zeroes the historical Saved of that transfer
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-02-10, confirmed
    And the realized Saved for 2026-02 is R$ 500.00
    When I change the purpose of account "Reserve" to "spending"
    And I confirm the warning
    Then the realized Saved for 2026-02 is R$ 0.00
    And the realized Inflows for 2026-02 are R$ 0.00

  @CON-12 @CON-6 @PRJ-5
  Scenario: Changing the purpose changes the consolidated balance
    Given the transfer "Save" of R$ 300.00 from account "Nubank" to account "Reserve" on 2026-03-01, confirmed
    And the consolidated projected balance on 2026-03-15 is R$ 700.00
    When I change the purpose of account "Reserve" to "spending"
    And I confirm the warning
    Then the consolidated projected balance on 2026-03-15 is R$ 1,000.00

  @CON-12 @LAN-6 @IND-3 @edge
  Scenario: The daily spending flag stays saved and ignored while the account is saving
    Given the expense "Bread" of R$ 12.00 in account "Wallet" on 2026-03-14, confirmed
    And the expense "Bread" is daily spending
    And the realized Daily spending for 2026-03 is R$ 12.00
    When I change the purpose of account "Wallet" to "saving"
    And I confirm the warning
    Then the realized Daily spending for 2026-03 is R$ 0.00
    And the expense "Bread" still has the daily spending flag saved

  @CON-12 @LAN-6 @IND-3 @edge
  Scenario: The daily spending flag applies again when the account goes back to spending
    Given the expense "Bread" of R$ 12.00 in account "Wallet" on 2026-03-14, confirmed
    And the expense "Bread" is daily spending
    And I change the purpose of account "Wallet" to "saving" and confirm the warning
    When I change the purpose of account "Wallet" to "spending"
    And I confirm the warning
    Then the realized Daily spending for 2026-03 is R$ 12.00

  @CON-10 @CON-12 @DIA-10 @CAR-3 @error
  Scenario Outline: An account with a spending role cannot become saving
    Given <role>
    When I change the purpose of account "<account>" to "saving"
    Then the operation is blocked with the message "<message>"
    And the account "<account>" has purpose "spending"

    Examples:
      | role                                                                                             | account | message                                                                     |
      | "Nubank" is the default account                                                                  | Nubank  | The default account must be a spending account. Choose another one first    |

    @later
    Examples:
      | role                                                                                             | account | message                                                                     |
      | the daily budget source is account "Wallet"                                                      | Wallet  | The daily budget source must be a spending account. Change the source first |
      | the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Wallet" | Wallet  | This account pays card Black. Change the card's account first               |
