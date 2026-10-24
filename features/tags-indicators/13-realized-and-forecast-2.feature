Feature: Past month shows only realized values

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the expense "Water" of R$ 80.00 in account "Nubank" on 2026-02-10, confirmed
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-02-27, planned

  @IND-11 @STA-3
  Scenario: A past month with an unconfirmed planned entry shows only realized values and warns
    Then the realized Outflows for 2026-02 are R$ 80.00
    And the forecast version for 2026-02 is not shown
    And I see the warning "1 planned entry from February has not been confirmed yet"

  @IND-11
  Scenario: A past month without pending planned entries shows no warning
    When I delete the expense "Electricity"
    Then the realized Outflows for 2026-02 are R$ 80.00
    And I do not see a warning about unconfirmed planned entries in 2026-02

  @IND-11 @STA-5
  Scenario: Confirming the overdue entry with a date in another month changes the accrual
    When I confirm the expense "Electricity" with amount R$ 203.40 on 2026-03-02
    Then the realized Outflows for 2026-02 are R$ 80.00
    And the realized Outflows for 2026-03 are R$ 203.40
    And I do not see a warning about unconfirmed planned entries in 2026-02

  @IND-11 @GER-3
  Scenario: At the turn of the month, the month that ended loses its forecast version
    Given the expense "Internet" of R$ 120.00 in account "Nubank" on 2026-03-31, planned
    Then the forecast Outflows for 2026-03 include R$ 120.00 from the expense "Internet"
    When the day turns to 2026-04-01
    Then the forecast version for 2026-03 is not shown
    And I see the warning "1 planned entry from March has not been confirmed yet"
