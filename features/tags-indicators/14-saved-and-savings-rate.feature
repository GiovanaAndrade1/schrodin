Feature: Saved and savings rate

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And the account "Savings" of kind "savings" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01

  @IND-6 @TRF-4
  Scenario Outline: Only a transfer between different purposes counts in Saved
    Given the transfer "Movement" of R$ 500.00 from account "<source>" to account "<destination>" on 2026-02-10, confirmed
    Then the realized Saved for 2026-02 is <saved>

    Examples:
      | source  | destination | saved      |
      | Nubank  | Reserve     | R$ 500.00  |
      | Wallet  | Savings     | R$ 500.00  |
      | Reserve | Nubank      | -R$ 500.00 |
      | Nubank  | Wallet      | R$ 0.00    |
      | Reserve | Savings     | R$ 0.00    |

  @IND-6 @IND-11 @TRF-5
  Scenario: A planned transfer counts only in forecast Saved
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-30, planned
    Then the realized Saved for 2026-03 is R$ 0.00
    And the forecast Saved for 2026-03 is R$ 500.00

  @IND-6 @IND-7 @edge
  Scenario: Negative Saved when the withdrawal exceeds what was saved
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-02-05, confirmed
    And the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-02-06, confirmed
    And the transfer "Withdrawal" of R$ 2,000.00 from account "Reserve" to account "Nubank" on 2026-02-20, confirmed
    Then the realized Saved for 2026-02 is -R$ 1,500.00
    And the realized savings rate for 2026-02 is -30.0%

  @IND-6 @IND-12
  Scenario: Yield and fee inside the saving account do not touch Saved
    Given the income "Yield" of R$ 32.10 in account "Reserve" on 2026-02-28, confirmed
    And the expense "Fee" of R$ 5.00 in account "Reserve" on 2026-02-28, confirmed
    Then the realized Saved for 2026-02 is R$ 0.00
    And the actual balance of account "Reserve" is R$ 5,027.10

  @IND-7 @GER-10 @edge
  Scenario Outline: Savings rate calculation and rounding (half away from zero)
    Given in 2026-02 the realized Inflows are <inflows> and the realized Saved is <saved>
    Then the realized savings rate for 2026-02 is <percentage>

    Examples:
      | inflows     | saved       | percentage |
      | R$ 5,000.00 | R$ 500.00   | 10.0%      |
      | R$ 6,000.00 | R$ 1,000.00 | 16.7%      |
      | R$ 3,000.00 | R$ 1,000.00 | 33.3%      |
      | R$ 7,500.00 | R$ 700.00   | 9.3%       |
      | R$ 1,600.00 | R$ 100.00   | 6.3%       |
      | R$ 1,600.00 | -R$ 100.00  | -6.3%      |
      | R$ 5,000.00 | R$ 0.00     | 0.0%       |
      | R$ 5,000.00 | R$ 6,000.00 | 120.0%     |

  @IND-7 @error @edge
  Scenario Outline: Without Inflows the savings rate is not shown
    Given in 2026-02 the realized Inflows are R$ 0.00 and the realized Saved is <saved>
    Then the realized savings rate for 2026-02 is not shown
    And no division error occurs

    Examples:
      | saved      |
      | R$ 500.00  |
      | R$ 0.00    |
      | -R$ 200.00 |
