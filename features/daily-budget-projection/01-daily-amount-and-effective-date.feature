Feature: Daily amount and effective date
  As a user
  I want to set how much I spend per day on small purchases, with an effective date
  In order for the projection to reserve that money without rewriting the past

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And "Nubank" is the default account
    And the daily amount is R$ 50.00 since 2026-01-01

  @DIA-1 @DIA-2 @DIA-9
  Scenario: A change effective from today applies today and does not change yesterday
    When I change the daily amount to R$ 40.00 from 2026-03-15
    Then the daily amount in effect on 2026-03-15 is R$ 40.00
    And the daily reserve on 2026-03-15 is R$ 40.00
    And the daily budget from 2026-03-14 to 2026-03-14 has budgeted R$ 50.00, spent R$ 0.00 and surplus R$ 50.00
    And the daily budget from 2026-03-15 to 2026-03-15 has budgeted R$ 40.00, spent R$ 0.00 and surplus R$ 40.00

  @DIA-2 @DIA-7 @PRJ-3
  Scenario: A change with a future effective date only changes the projection from that date on
    When I change the daily amount to R$ 80.00 from 2026-04-01
    Then the daily reserve on 2026-03-31 is R$ 50.00
    And the daily reserve on 2026-04-01 is R$ 80.00
    And the projected balance of account "Nubank" on 2026-03-31 is R$ 150.00
    And the projected balance of account "Nubank" on 2026-04-01 is R$ 70.00
    And the projected balance of account "Nubank" on 2026-04-02 is -R$ 10.00

  @DIA-2 @error
  Scenario: A change with a past effective date is blocked
    When I change the daily amount to R$ 40.00 from 2026-03-14
    Then the operation is blocked with the message "A daily amount change can only take effect from today on"
    And the daily amount in effect on 2026-03-14 is R$ 50.00
    And the daily amount in effect on 2026-03-15 is R$ 50.00

  @DIA-2 @edge
  Scenario: Several future daily amount periods coexist, each in its own period
    When I change the daily amount to R$ 60.00 from 2026-04-01
    And I change the daily amount to R$ 70.00 from 2026-05-01
    Then the daily amount in effect on 2026-03-31 is R$ 50.00
    And the daily amount in effect on 2026-04-30 is R$ 60.00
    And the daily amount in effect on 2026-05-01 is R$ 70.00

  @DIA-2 @edge
  Scenario: A new change on the same date as a scheduled daily amount period replaces the previous one
    Given the daily amount changes to R$ 60.00 from 2026-04-01
    When I change the daily amount to R$ 65.00 from 2026-04-01
    Then the daily amount in effect on 2026-04-01 is R$ 65.00
    And there is a single daily amount period starting on 2026-04-01

  @DIA-2
  Scenario: A future daily amount period can be deleted
    Given the daily amount changes to R$ 60.00 from 2026-04-01
    When I delete the daily amount effective from 2026-04-01
    Then the daily amount in effect on 2026-04-01 is R$ 50.00
    And the daily reserve on 2026-04-01 is R$ 50.00

  @DIA-2 @error
  Scenario Outline: A daily amount period from today or the past cannot be deleted
    Given the daily amount changes to R$ 40.00 from 2026-03-15
    When I delete the daily amount effective from <date>
    Then the operation is blocked with the message "You can only delete a future daily amount period"
    And the daily amount in effect on <date> is <amount>

    Examples:
      | date       | amount   |
      | 2026-03-15 | R$ 40.00 |
      | 2026-01-01 | R$ 50.00 |

  @DIA-2 @DIA-5
  Scenario: A scheduled daily amount period takes effect by itself when the day arrives
    Given today is 2026-03-31
    And the daily amount changes to R$ 80.00 from 2026-04-01
    When the day turns to 2026-04-01
    Then the daily reserve on 2026-04-01 is R$ 80.00
    And the daily budget from 2026-03-31 to 2026-03-31 has budgeted R$ 50.00, spent R$ 0.00 and surplus R$ 50.00

  @DIA-1 @DIA-5 @DIA-7
  Scenario: A zero daily amount turns off the reserve from its effective date
    When I change the daily amount to R$ 0.00 from 2026-04-01
    Then the daily reserve on 2026-04-01 is R$ 0.00
    And the projected balance of account "Nubank" on 2026-03-31 is R$ 150.00
    And the projected balance of account "Nubank" on 2026-04-30 is R$ 150.00

  @DIA-1 @GER-8 @error
  Scenario Outline: An invalid daily amount is rejected
    When I change the daily amount to <amount> from 2026-03-15
    Then the operation is blocked with the message "<message>"
    And the daily amount in effect on 2026-03-15 is R$ 50.00

    Examples:
      | amount            | message                                                  |
      | -R$ 10.00         | The daily amount can't be negative                       |
      | R$ 100,000,000.00 | The daily amount exceeds the maximum of R$ 99,999,999.99 |

  @DIA-1 @GER-8 @edge
  Scenario: A daily amount at the maximum allowed is accepted
    When I change the daily amount to R$ 99,999,999.99 from 2026-04-01
    Then the daily amount in effect on 2026-04-01 is R$ 99,999,999.99
