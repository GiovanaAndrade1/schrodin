Feature: Default account

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 100.00 on 2026-01-01
    And "Nubank" is the default account

  @CON-10
  Scenario: The default account comes preselected when adding an entry
    When I open the new expense form
    Then the selected account is "Nubank"

  @CON-10 @DIA-10
  Scenario: Changing the default account changes the preselection and the daily budget source
    When I set "Wallet" as the default account
    Then "Wallet" is the default account
    And "Nubank" is not the default account
    And the daily budget source is account "Wallet"
    When I open the new expense form
    Then the selected account is "Wallet"

  @CON-10 @error
  Scenario: A saving account cannot be the default account
    Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    When I set "Reserve" as the default account
    Then the operation is blocked with the message "The default account must be a spending account"
    And "Nubank" is still the default account

  @CON-10 @CON-5 @DIA-7 @DIA-10
  Scenario: The daily reserve comes out of the default account in the projection
    Given the daily amount is R$ 50.00 since 2026-01-01
    Then the projected balance of account "Nubank" on 2026-03-16 is R$ 900.00
    And the projected balance of account "Wallet" on 2026-03-16 is R$ 100.00
