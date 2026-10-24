Feature: Projected balance thermometer
  As a user
  I want a color on each consolidated projected balance
  In order to know at a glance whether I am fine

  Background:
    Given today is 2026-03-15
    And the daily amount is R$ 0.00 since 2026-01-01

  @TER-1 @TER-2 @edge
  Scenario Outline: Default bands with [min, max) intervals
    Given the account "Nubank" of kind "checking" with opening balance <balance> on 2026-03-01
    Then the thermometer color on 2026-03-15 is "<color>"

    Examples:
      | balance          | color       |
      | -R$ 10,000.00    | red         |
      | -R$ 500.01       | red         |
      | -R$ 500.00       | pink        |
      | -R$ 0.01         | pink        |
      | R$ 0.00          | yellow      |
      | R$ 999.99        | yellow      |
      | R$ 1,000.00      | light green |
      | R$ 1,999.99      | light green |
      | R$ 2,000.00      | dark green  |
      | R$ 99,999,999.99 | dark green  |

  @TER-1 @CON-6
  Scenario: The thermometer uses only the consolidated balance; a saving account does not paint it green
    Given the account "Nubank" of kind "checking" with opening balance R$ 500.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 10,000.00 on 2026-03-01
    Then the thermometer color on 2026-03-15 is "yellow"

  @TER-1 @PRJ-5
  Scenario: The per-account projection has no thermometer
    Given the account "Nubank" of kind "checking" with opening balance R$ 500.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 10,000.00 on 2026-03-01
    Then the projection of account "Nubank" shows no thermometer color
    And the projection of account "Reserve" shows no thermometer color

  @TER-3 @TER-2
  Scenario Outline: Valid custom thresholds
    Given the account "Nubank" of kind "checking" with opening balance <balance> on 2026-03-01
    When I save the thermometer thresholds "-R$ 1,000.00 · R$ 0.00 · R$ 500.00 · R$ 3,000.00"
    Then the thermometer color on 2026-03-15 is "<color>"

    Examples:
      | balance      | color       |
      | -R$ 1,000.01 | red         |
      | -R$ 1,000.00 | pink        |
      | R$ 499.99    | yellow      |
      | R$ 500.00    | light green |
      | R$ 2,000.00  | light green |
      | R$ 2,999.99  | light green |
      | R$ 3,000.00  | dark green  |

  @TER-3 @TER-2 @error
  Scenario Outline: Out-of-order, equal or incomplete thresholds are not saved and the previous ones remain
    When I save the thermometer thresholds "<thresholds>"
    Then the operation is blocked with the message "<message>"
    And the thermometer thresholds are still "-R$ 500.00 · R$ 0.00 · R$ 1,000.00 · R$ 2,000.00"

    Examples:
      | thresholds                                       | message                               |
      | -R$ 500.00 · R$ 1,000.00 · R$ 0.00 · R$ 2,000.00 | Thresholds must be in ascending order |
      | -R$ 500.00 · R$ 0.00 · R$ 0.00 · R$ 2,000.00     | Thresholds can't be equal             |
      | R$ 2,000.00 · R$ 1,000.00 · R$ 0.00 · -R$ 500.00 | Thresholds must be in ascending order |
      | -R$ 500.00 · R$ 0.00 · R$ 1,000.00               | Enter the 4 thresholds                |

  @TER-2 @TER-3
  Scenario: The 5 colors are fixed
    Then the thermometer has the colors "red · pink · yellow · light green · dark green", in that order
    And there is no option to change the colors or the number of bands

  @TER-4 @IND-8 @GER-10
  Scenario Outline: Relative mode: thresholds in multiples of the cost of living, rounded half away from zero
    Given the account "Nubank" of kind "checking" with opening balance <balance> on 2026-03-01
    And the cost of living is <cost of living>
    And the thermometer is in relative mode with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then the thermometer thresholds are "<thresholds>"
    And the thermometer color on 2026-03-15 is "<color>"

    Examples:
      | cost of living | thresholds                                       | balance     | color       |
      | R$ 4,000.00    | -R$ 500.00 · R$ 0.00 · R$ 1,000.00 · R$ 2,000.00 | R$ 1,000.00 | light green |
      | R$ 6,000.00    | -R$ 750.00 · R$ 0.00 · R$ 1,500.00 · R$ 3,000.00 | R$ 1,000.00 | yellow      |
      | R$ 6,000.00    | -R$ 750.00 · R$ 0.00 · R$ 1,500.00 · R$ 3,000.00 | -R$ 750.00  | pink        |
      | R$ 6,000.00    | -R$ 750.00 · R$ 0.00 · R$ 1,500.00 · R$ 3,000.00 | -R$ 750.01  | red         |
      | R$ 6,000.00    | -R$ 750.00 · R$ 0.00 · R$ 1,500.00 · R$ 3,000.00 | R$ 3,000.00 | dark green  |
      | R$ 3,333.33    | -R$ 416.67 · R$ 0.00 · R$ 833.33 · R$ 1,666.67   | R$ 833.33   | light green |
      | R$ 3,333.33    | -R$ 416.67 · R$ 0.00 · R$ 833.33 · R$ 1,666.67   | R$ 833.32   | yellow      |

  @TER-4 @IND-8
  Scenario: The month rollover changes the cost of living and the color of the same balance
    Given today is 2026-03-31
    And the account "Nubank" of kind "checking" with opening balance R$ 1,200.00 on 2025-12-01
    And the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,800.00    |
      | 2026-01 | R$ 4,000.00    |
      | 2026-02 | R$ 4,200.00    |
      | 2026-03 | R$ 9,800.00    |
    And the thermometer is in relative mode with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then the cost of living is R$ 4,000.00
    And the thermometer color on 2026-03-31 is "light green"
    And the thermometer color on 2026-04-15 is "light green"
    When the day turns to 2026-04-01
    Then the cost of living is R$ 6,000.00
    And the thermometer color on 2026-04-01 is "yellow"
    And the thermometer color on 2026-04-15 is "yellow"

  @TER-4 @IND-8 @GER-10 @edge
  Scenario: A relative threshold uses the already rounded cost of living
    Given today is 2026-03-31
    And the account "Nubank" of kind "checking" with opening balance R$ 1,500.00 on 2025-12-01
    And the realized Total outflows were:
      | month   | Total outflows |
      | 2025-12 | R$ 3,000.00    |
      | 2026-01 | R$ 3,000.00    |
      | 2026-02 | R$ 3,000.02    |
    And the thermometer is in relative mode with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then the cost of living is R$ 3,000.01
    And the thermometer thresholds are "-R$ 375.00 · R$ 0.00 · R$ 750.00 · R$ 1,500.01"
    And the thermometer color on 2026-03-31 is "light green"

  @TER-4 @IND-8
  Scenario: With no computable cost of living, relative bands use the absolute ones with a warning
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,200.00 on 2026-03-01
    And the cost of living is "no data"
    When I turn on relative bands with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then I see the warning "No cost of living calculated yet: using the bands in reais"
    And the thermometer color on 2026-03-15 is "light green"

  @TER-4 @IND-8 @edge
  Scenario: A zero cost of living falls back to the absolute bands with a warning
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,200.00 on 2026-03-01
    And the cost of living is R$ 0.00
    And the thermometer is in relative mode with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then I see the warning "No cost of living calculated yet: using the bands in reais"
    And the thermometer color on 2026-03-15 is "light green"

  @TER-4
  Scenario: Relative mode comes with the default multipliers
    When I turn on relative bands
    Then the thermometer multipliers are "-0.125 · 0 · 0.25 · 0.5"

  @TER-4 @TER-3 @IND-8 @edge
  Scenario Outline: A negative cost of living or one that collapses the thresholds falls back to the absolute bands
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,200.00 on 2026-03-01
    And the cost of living is <cost of living>
    And the thermometer is in relative mode with multipliers "-0.125 · 0 · 0.25 · 0.5"
    Then I see the warning "No cost of living calculated yet: using the bands in reais"
    And the thermometer thresholds are "-R$ 500.00 · R$ 0.00 · R$ 1,000.00 · R$ 2,000.00"
    And the thermometer color on 2026-03-15 is "light green"

    Examples:
      | cost of living |
      | -R$ 200.00     |
      | R$ 0.01        |
