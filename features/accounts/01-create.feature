Feature: Account creation

  Background:
    Given today is 2026-03-15

  @CON-1 @CON-2 @CON-6
  Scenario: Create a checking account with valid data
    When I create the account "Itaú" of kind "checking" with opening balance R$ 500.00 on 2026-03-01
    Then the account "Itaú" is active
    And the account "Itaú" has purpose "spending"
    And the opening date of account "Itaú" is 2026-03-01
    And the actual balance of account "Itaú" is R$ 500.00

  @CON-6
  Scenario Outline: The default purpose comes from the kind
    When I create the account "<name>" of kind "<kind>" with opening balance R$ 0.00 on 2026-03-01
    Then the account "<name>" has purpose "<purpose>"

    Examples:
      | name          | kind       | purpose  |
      | Itaú          | checking   | spending |
      | Pocket        | cash       | spending |
      | Caixa Savings | savings    | saving   |
      | Emergency     | reserve    | saving   |
      | Brokerage     | investment | saving   |

  @CON-6
  Scenario: The user changes the suggested purpose on creation
    When I create the account "Savings Box" of kind "checking" with purpose "saving" and opening balance R$ 2,000.00 on 2026-03-01
    Then the account "Savings Box" has purpose "saving"

  @CON-2 @GER-3
  Scenario: The opening date comes prefilled with today
    When I open the new account form
    Then the opening date comes prefilled with 2026-03-15

  @GER-2
  Scenario: An account has no currency choice: everything is in reais
    When I open the new account form
    Then there is no currency field
    And the opening balance comes prefilled with "R$ 0,00"

  @GER-6 @DIA-3 @later
  Scenario: An account records when it was created, regardless of the opening date
    Given the device clock reads 2026-03-15T13:00:00Z
    When I create the account "Itaú" of kind "checking" with opening balance R$ 500.00 on 2026-01-01
    Then the account "Itaú" has createdAt and updatedAt 2026-03-15T13:00:00Z
    And the creation date of account "Itaú" is 2026-03-15
    When the device clock reads 2026-03-16T12:00:00Z
    And I rename the account "Itaú" to "Itaú PJ"
    Then the account "Itaú PJ" keeps createdAt 2026-03-15T13:00:00Z and has updatedAt 2026-03-16T12:00:00Z

  @CON-2 @edge
  Scenario: An opening balance not entered becomes zero
    When I create the account "Itaú" of kind "checking" without entering the opening balance, on 2026-03-01
    Then the actual balance of account "Itaú" is R$ 0.00

  @CON-2 @GER-8
  Scenario Outline: Accepted opening balance amounts
    When I create the account "Itaú" of kind "checking" with opening balance <amount> on 2026-03-01
    Then the account "Itaú" is active
    And the actual balance of account "Itaú" is <amount>

    Examples:
      | amount            |
      | R$ 0.00           |
      | -R$ 1,500.00      |
      | R$ 0.01           |
      | R$ 99,999,999.99  |
      | -R$ 99,999,999.99 |

  @CON-2 @GER-8 @error @edge
  Scenario Outline: An opening balance one cent beyond the maximum is blocked
    When I try to create the account "Itaú" of kind "checking" with opening balance <amount> on 2026-03-01
    Then the operation is blocked with the message "The maximum amount is R$ 99,999,999.99"
    And the account "Itaú" does not exist

    Examples:
      | amount             |
      | R$ 100,000,000.00  |
      | -R$ 100,000,000.00 |

  @CON-2 @edge
  Scenario Outline: An opening date of today or in the past is accepted
    When I create the account "Itaú" of kind "checking" with opening balance R$ 100.00 on <date>
    Then the opening date of account "Itaú" is <date>

    Examples:
      | date       |
      | 2026-03-15 |
      | 2026-03-14 |
      | 2020-01-01 |

  @CON-2 @error @edge
  Scenario Outline: An invalid opening date is blocked
    When I try to create the account "Itaú" of kind "checking" with opening balance R$ 100.00 on <date>
    Then the operation is blocked with the message "<message>"

    Examples:
      | date       | message                                 |
      | 2026-03-16 | The opening date can't be in the future |
      | 2027-01-01 | The opening date can't be in the future |
      | 2026-02-29 | Invalid date                            |

  @CON-2 @error
  Scenario: The opening date is required
    When I try to create the account "Itaú" of kind "checking" with opening balance R$ 100.00 clearing the opening date
    Then the operation is blocked with the message "Enter the opening date"

  @CON-1 @GER-9
  Scenario Outline: Valid names at the limits and with trim
    When I create the account "<typed>" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then there is the active account "<saved name>"

    Examples:
      | typed                                    | saved name                               |
      | A                                        | A                                        |
      | Long Term Investments Savings Account 01 | Long Term Investments Savings Account 01 |

  @CON-1 @GER-9
  Scenario: Leading and trailing spaces are removed before saving
    When I create the account "  Itaú  " of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then there is the active account "Itaú"

  @CON-1 @GER-9 @edge
  Scenario: The 40-character limit applies after the trim
    When I create the account "  Long Term Investments Savings Account 01  " of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then there is the active account "Long Term Investments Savings Account 01"

  @CON-1 @error
  Scenario: An empty name is blocked
    When I try to create the account "" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then the operation is blocked with the message "Enter the account name"

  @CON-1 @GER-9 @error @edge
  Scenario: A name with only spaces counts as empty
    When I try to create the account "   " of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then the operation is blocked with the message "Enter the account name"

  @CON-1 @error @edge
  Scenario: A 41-character name is blocked
    When I try to create the account "Long Term Investments Savings Account 012" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then the operation is blocked with the message "The account name can have at most 40 characters"

  @CON-1 @GER-9 @error
  Scenario Outline: A name equal to another active account's, compared normalized
    Given the account "Nubank" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    And the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    And the account "Savings" of kind "savings" with opening balance R$ 0.00 on 2026-01-01
    When I try to create the account "<typed>" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then the operation is blocked with the message "An active account with this name already exists"

    Examples:
      | typed   |
      | Nubank  |
      | nubank  |
      | NUBANK  |
      | Núbank  |
      | itau    |
      | ITAÚ    |
      | Itáu    |
      | sávings |

  @CON-1 @GER-9
  Scenario: Repeated inner spaces are collapsed on save
    When I create the account "Banco   Inter" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then there is the active account "Banco Inter"

  @CON-1 @GER-9 @edge
  Scenario: Length counts visible characters, not bytes or code points
    When I create the account "Family Long Term Savings Account 01234 👨‍👩‍👧" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then there is the active account "Family Long Term Savings Account 01234 👨‍👩‍👧"

  @CON-1 @GER-9 @error @edge
  Scenario: Repeated inner spaces do not get around uniqueness
    Given the account "Banco Inter" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    When I try to create the account "Banco  Inter" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    Then the operation is blocked with the message "An active account with this name already exists"

  @CON-1 @GER-5
  Scenario: The name of an archived account can be reused
    Given the archived account "Nubank" of kind "checking"
    When I create the account "nubank" of kind "checking" with opening balance R$ 300.00 on 2026-03-01
    Then there is the active account "nubank"
    And the archived account "Nubank" still exists

  @CON-10
  Scenario: The first account created becomes the default account
    Given there is no account
    When I create the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    Then "Nubank" is the default account

  @CON-10 @edge
  Scenario: A saving account created first does not become the default
    Given there is no account
    When I create the account "Reserve" of kind "reserve" with opening balance R$ 0.00 on 2026-01-01
    Then there is no default account
    When I create the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    Then "Nubank" is the default account

  @CON-10
  Scenario: Accounts created later do not take the default's place
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And "Nubank" is the default account
    When I create the account "Wallet" of kind "cash" with opening balance R$ 50.00 on 2026-03-01
    Then "Nubank" is still the default account

  @CON-2 @IND-1 @edge
  Scenario: The opening balance is not an Inflow
    Given the account "Nubank" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    When I create the account "Itaú" of kind "checking" with opening balance R$ 3,000.00 on 2026-03-10
    Then the realized Inflows for 2026-03 are R$ 0.00
    And the actual balance of account "Itaú" is R$ 3,000.00
