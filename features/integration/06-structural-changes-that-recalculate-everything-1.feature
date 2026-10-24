Feature: Changing an account's purpose

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 300.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the daily amount is R$ 50.00 since 2026-01-01
    And the tag "groceries" that marks daily spending
    And the income "Salary" of R$ 4,000.00 in account "Nubank" on 2026-02-05, confirmed, with the tag "salary"
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-02-08, confirmed, with the tag "home"
    And the transfer "Change" of R$ 200.00 from account "Nubank" to account "Wallet" on 2026-02-10, confirmed
    And the expense "Market" of R$ 120.00 in account "Wallet" on 2026-02-20, confirmed, with the tag "groceries"
    And the income "Salary" of R$ 4,000.00 in account "Nubank" on 2026-03-05, confirmed, with the tag "salary"
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-08, confirmed, with the tag "home"
    And the expense "Popcorn" of R$ 30.00 in account "Wallet" on 2026-03-15, confirmed, with the tag "groceries"
    And the expense "Dentist" of R$ 150.00 in account "Wallet" on 2026-03-25, planned, with the tag "health"
    And the thermometer is in relative mode with the default multipliers

  @integration @CON-12 @CON-6 @LAN-6 @DIA-5 @PRJ-5 @TRF-4 @IND-2 @IND-3 @IND-5 @IND-6 @IND-7 @IND-8 @IND-12 @TAG-9 @TER-4
  Scenario: Wallet becomes saving and back: consolidated balance, reserve, history, tags and thermometer
    Then the consolidated actual balance is R$ 8,150.00
    And the daily reserve on 2026-03-15 is R$ 20.00
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 8,130.00 |
      | 2026-03-24 | R$ 7,680.00 |
      | 2026-03-25 | R$ 7,480.00 |
    And the realized indicators for 2026-02 are Inflows R$ 4,000.00, Outflows R$ 1,500.00, Daily spending R$ 120.00, Performance R$ 2,380.00 and Saved R$ 0.00
    And the realized Daily spending for 2026-03 is R$ 30.00
    And the cost of living is R$ 1,620.00
    And the thermometer thresholds are "-R$ 202.50 · R$ 0.00 · R$ 405.00 · R$ 810.00"
    When I change the purpose of account "Wallet" to "saving"
    Then I see the warning "Changing the purpose recalculates the indicators for this account's entire history"
    When I confirm the warning
    Then the consolidated actual balance is R$ 7,800.00
    And the expense "Popcorn" is still flagged as daily spending, but the flag is ignored
    And the daily reserve on 2026-03-15 is R$ 50.00
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-15 | R$ 7,750.00 |
      | 2026-03-24 | R$ 7,300.00 |
      | 2026-03-25 | R$ 7,250.00 |
    And the projected balance of account "Wallet" on 2026-03-25 is R$ 200.00
    And the realized indicators for 2026-02 are Inflows R$ 4,000.00, Outflows R$ 1,500.00, Daily spending R$ 0.00, Performance R$ 2,500.00 and Saved R$ 200.00
    And the realized savings rate for 2026-02 is 5.0%
    And the realized Daily spending for 2026-03 is R$ 0.00
    And the tag "groceries" does not appear in the realized tag report for 2026-02
    And the cost of living is R$ 1,500.00
    And the thermometer thresholds are "-R$ 187.50 · R$ 0.00 · R$ 375.00 · R$ 750.00"
    When I change the purpose of account "Wallet" to "spending" and confirm the warning
    Then the consolidated actual balance is R$ 8,150.00
    And the daily reserve on 2026-03-15 is R$ 20.00
    And the consolidated projected balance on 2026-03-25 is R$ 7,480.00
    And the realized indicators for 2026-02 are Inflows R$ 4,000.00, Outflows R$ 1,500.00, Daily spending R$ 120.00, Performance R$ 2,380.00 and Saved R$ 0.00
    And the cost of living is R$ 1,620.00

  @integration @CON-12 @CON-10 @DIA-10 @CAR-3 @error
  Scenario Outline: Becoming saving is blocked when the account supports another feature
    Given <setup>
    When I change the purpose of account "<account>" to "saving"
    Then the operation is blocked with the message "<message>"
    And the consolidated actual balance is R$ 8,150.00

    Examples:
      | setup                                                                                            | account | message                                                                     |
      | "Nubank" is the default account                                                                  | Nubank  | The default account must be a spending account. Choose another one first    |
      | the daily budget source is account "Wallet"                                                      | Wallet  | The daily budget source must be a spending account. Change the source first |
      | the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Wallet" | Wallet  | This account pays card Black. Change the card's account first               |
