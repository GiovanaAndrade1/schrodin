Feature: "Today" in the user's time zone applied to accounts

  @GER-3 @CON-2 @error @edge
  Scenario: "Today" is the time zone's, not UTC's
    Given the user's time zone is "America/Sao_Paulo"
    And the device clock reads 2026-03-16T02:30:00Z
    When I try to create the account "Itaú" of kind "checking" with opening balance R$ 100.00 on 2026-03-16
    Then the operation is blocked with the message "The opening date can't be in the future"

  @GER-3 @CON-2 @edge
  Scenario: Midnight rollover with the app open allows the new date
    Given today is 2026-03-15
    And the app is open
    When the day turns to 2026-03-16
    And I create the account "Itaú" of kind "checking" with opening balance R$ 100.00 on 2026-03-16
    Then the opening date of account "Itaú" is 2026-03-16

  @GER-3 @AJU-1
  Scenario: An adjustment made late at night takes the local date
    Given the user's time zone is "America/Sao_Paulo"
    And the device clock reads 2026-03-16T02:00:00Z
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    When I adjust the balance of account "Nubank" to R$ 1,010.00
    Then there is an inflow adjustment of R$ 10.00 in account "Nubank" on 2026-03-15, confirmed

  @GER-3 @CON-2 @edge
  Scenario: Changing the time zone does not touch the opening date, even if it becomes "future"
    Given the user's time zone is "America/Sao_Paulo"
    And the device clock reads 2026-03-16T03:30:00Z
    And I create the account "Itaú" of kind "checking" with opening balance R$ 100.00 on 2026-03-16
    When I change the time zone to "America/Manaus"
    Then today is 2026-03-15
    And the opening date of account "Itaú" is 2026-03-16
    And the account "Itaú" is active
    And I can rename the account "Itaú" to "Itaú PJ" without a date error

  @GER-3 @INV-6 @CON-4 @edge
  Scenario: A confirmed entry that becomes "tomorrow" when switching the time zone west stays confirmed
    Given the user's time zone is "America/Sao_Paulo"
    And the device clock reads 2026-03-16T03:30:00Z
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the expense "Bakery" of R$ 25.00 in account "Nubank" on 2026-03-16, confirmed
    When I change the time zone to "America/Manaus"
    Then I see the confirmation prompt "Changing the time zone changes today's date. No entry date will be changed"
    When I confirm the time zone change
    Then today is 2026-03-15
    And I see the warning "1 confirmed entry now has tomorrow's date in the new time zone"
    And the expense "Bakery" is "confirmed"
    And the date of the expense "Bakery" is 2026-03-16
    And the actual balance of account "Nubank" is R$ 975.00

  @GER-3 @CON-3 @AJU-1 @error @edge
  Scenario: An adjustment is blocked when the time zone left the opening balance in the future
    Given the user's time zone is "America/Manaus"
    And the device clock reads 2026-03-16T03:30:00Z
    And the account "Itaú" of kind "checking" with opening balance R$ 100.00 on 2026-03-16
    When I adjust the balance of account "Itaú" to R$ 120.00
    Then the operation is blocked with the message "The date can't be before the opening balance of account Itaú (2026-03-16)"
