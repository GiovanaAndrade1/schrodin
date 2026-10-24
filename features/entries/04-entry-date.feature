Feature: Entry date limits

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months

  @LAN-7 @CON-3 @edge
  Scenario Outline: The minimum date in an account is the opening date
    When I add the <type> "Test" of R$ 10.00 to account "Wallet" on <date>
    Then the result is "<result>"

    Examples:
      | type    | date       | result                                                                               |
      | expense | 2026-03-01 | accepted                                                                             |
      | expense | 2026-02-28 | blocked: The date can't be before the opening balance of account Wallet (2026-03-01) |
      | income  | 2026-03-01 | accepted                                                                             |
      | income  | 2026-02-28 | blocked: The date can't be before the opening balance of account Wallet (2026-03-01) |

  @LAN-7 @CAR-8 @INV-7 @edge
  Scenario Outline: The minimum date on a card is its start date
    When I add <entry> to card "Purple" on <date>
    Then the result is "<result>"

    Examples:
      | entry                               | date       | result                                                          |
      | the expense "Book" of R$ 50.00      | 2026-01-01 | accepted                                                        |
      | the expense "Book" of R$ 50.00      | 2025-12-31 | blocked: The date can't be before the card's start (2026-01-01) |
      | the refund "Adjustment" of R$ 10.00 | 2026-01-01 | accepted                                                        |
      | the refund "Adjustment" of R$ 10.00 | 2025-12-31 | blocked: The date can't be before the card's start (2026-01-01) |

  @LAN-7 @GER-12 @PRJ-3 @edge
  Scenario Outline: The maximum date is the horizon end, inclusive
    Given the projection horizon is <months> months
    When I add the <type> "Test" of R$ 10.00 <source> on <date>
    Then the result is "<result>"

    Examples:
      | months | type    | source              | date       | result                                      |
      | 12     | expense | in account "Nubank" | 2027-03-15 | accepted                                    |
      | 12     | expense | in account "Nubank" | 2027-03-16 | blocked: The date can't be after 2027-03-15 |
      | 12     | expense | on card "Purple"    | 2027-03-16 | blocked: The date can't be after 2027-03-15 |
      | 12     | income  | in account "Nubank" | 2027-03-16 | blocked: The date can't be after 2027-03-15 |
      | 1      | expense | in account "Nubank" | 2026-04-15 | accepted                                    |
      | 1      | expense | in account "Nubank" | 2026-04-16 | blocked: The date can't be after 2026-04-15 |
      | 24     | expense | in account "Nubank" | 2028-03-15 | accepted                                    |
      | 24     | expense | in account "Nubank" | 2028-03-16 | blocked: The date can't be after 2028-03-15 |

  @LAN-7 @GER-12 @edge
  Scenario Outline: Horizon end when today is the end of the month
    Given today is <today>
    And the projection horizon is <months> months
    Then the latest allowed entry date is <maximum>

    Examples:
      | today      | months | maximum    |
      | 2026-08-31 | 6      | 2027-02-28 |
      | 2027-08-31 | 6      | 2028-02-29 |
      | 2026-01-31 | 1      | 2026-02-28 |
      | 2028-02-29 | 12     | 2029-02-28 |

  @LAN-7 @GER-3
  Scenario: The maximum date moves when the day turns
    When I add the expense "Insurance" of R$ 900.00 to account "Nubank" on 2027-03-16
    Then the operation is blocked with the message "The date can't be after 2027-03-15"
    When the day turns to 2026-03-16
    And I add the expense "Insurance" of R$ 900.00 to account "Nubank" on 2027-03-16
    Then the expense "Insurance" is "planned"

  @LAN-7 @GER-12 @edge
  Scenario: Reducing the horizon does not delete a manual entry beyond it
    Given the expense "Vehicle Tax" of R$ 1,800.00 in account "Nubank" on 2027-01-10, planned
    When I change the projection horizon to 6 months
    Then the expense "Vehicle Tax" still exists on 2027-01-10
    And the latest allowed entry date is 2026-09-15

  @GER-3 @STA-2 @edge
  Scenario: "Today" is computed in the user's time zone
    Given the user's time zone is "America/Manaus"
    And it is now 2026-03-15 23:30 in the user's time zone
    When I add the expense "Pizza" of R$ 60.00 to account "Nubank" on 2026-03-16
    Then the expense "Pizza" is "planned"
