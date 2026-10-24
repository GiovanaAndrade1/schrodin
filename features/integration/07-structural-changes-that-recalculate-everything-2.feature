Feature: An account that becomes spending when there is none

  @integration @CON-10 @CON-12 @DIA-10 @TRF-4 @IND-6 @IND-7 @PRJ-5
  Scenario: The only account that becomes spending becomes the default
    Given today is 2026-03-15
    And only the accounts "Reserve" (saving, R$ 5,000.00 on 2026-01-01) and "Savings" (savings, saving, R$ 2,000.00 on 2026-01-01) exist
    And the daily amount is R$ 50.00 since 2026-01-01
    And the transfer "Investment" of R$ 500.00 from account "Savings" to account "Reserve" on 2026-03-05, confirmed
    And there is no default account
    And the realized Saved for 2026-03 is R$ 0.00
    When I change the purpose of account "Savings" to "spending" and confirm the warning
    Then "Savings" is the default account and the daily budget source
    And the consolidated actual balance is R$ 1,500.00
    And the consolidated projected balance on 2026-03-15 is R$ 1,450.00
    And the realized Saved for 2026-03 is R$ 500.00
    And the savings rate for 2026-03 is not shown
