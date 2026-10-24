Feature: Account unarchiving

  Background:
    Given today is 2026-03-15

  @CON-11
  Scenario: Unarchive with no name collision
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the archived account "Wallet" of kind "cash"
    When I unarchive the account "Wallet"
    Then the account "Wallet" is active
    And the account "Wallet" appears in the account picker when adding an entry
    And the actual balance of account "Wallet" is R$ 0.00
    And "Nubank" is still the default account

  @CON-11 @GER-9 @error
  Scenario: Unarchiving with a colliding name (normalized) asks to rename
    Given the archived account "Wallet" of kind "cash"
    And the account "wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    When I unarchive the account "Wallet"
    Then I see the warning "An active account with this name already exists. Rename it to unarchive"
    And the archived account "Wallet" is still archived

  @CON-11
  Scenario: Renaming to a free name completes the unarchiving
    Given the archived account "Wallet" of kind "cash"
    And the account "wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    When I unarchive the account "Wallet" renaming it to "Old Wallet"
    Then there is the active account "Old Wallet"
    And there is the active account "wallet"

  @CON-11 @CON-1 @error
  Scenario: Renaming to another name in use is still blocked
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the archived account "Wallet" of kind "cash"
    And the account "wallet" of kind "cash" with opening balance R$ 0.00 on 2026-03-01
    When I unarchive the account "Wallet" renaming it to "NUBANK"
    Then the operation is blocked with the message "An active account with this name already exists"
    And the archived account "Wallet" is still archived

  @CON-10 @edge
  Scenario: Archiving the only active account leaves the app with no default account
    Given only the active account "Solo" of kind "checking" with opening balance R$ 0.00 on 2026-01-01 exists
    And "Solo" is the default account
    When I archive the account "Solo"
    Then the account "Solo" is archived
    And there is no default account
    When I create the account "New" of kind "checking" with opening balance R$ 0.00 on 2026-03-15
    Then "New" is the default account

  @CON-10 @CON-11 @edge
  Scenario: Unarchiving a saving account with no default does not make it the default
    Given the archived account "Safe" of kind "reserve"
    And there is no active account
    And there is no default account
    When I unarchive the account "Safe"
    Then the account "Safe" is active
    And there is no default account

  @CON-10 @CON-12 @edge
  Scenario: With no default, the account that becomes spending becomes the default
    Given the account "Safe" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And there is no active spending account
    And there is no default account
    When I change the purpose of account "Safe" to "spending"
    And I confirm the warning
    Then "Safe" is the default account

  @CON-11 @CON-10 @edge
  Scenario: Unarchiving when there is no active account makes it the default account
    Given the archived account "Wallet" of kind "cash"
    And there is no active account
    And there is no default account
    When I unarchive the account "Wallet"
    Then "Wallet" is the default account
