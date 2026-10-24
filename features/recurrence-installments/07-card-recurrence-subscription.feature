Feature: Recurring subscription on a card
  The card charge is automatic: the occurrence confirms itself when the date arrives

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months
    And the recurring expense "Netflix" of R$ 55.90 on card "Purple", monthly, starting 2026-03-20, for 12 occurrences

  @REC-9 @FAT-1 @REC-10
  Scenario: Each occurrence falls in the statement of its cycle
    Then the occurrences of series "Netflix" are:
      | k  | date       | status  | statement |
      | 1  | 2026-03-20 | planned | 2026-04   |
      | 2  | 2026-04-20 | planned | 2026-05   |
      | 10 | 2026-12-20 | planned | 2027-01   |
      | 11 | 2027-01-20 | planned | 2027-02   |
      | 12 | 2027-02-20 | planned | 2027-03   |

  @REC-9 @LIM-3
  Scenario: Planned occurrences do not use the limit
    Then the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Purple" after planned entries is R$ 4,329.20

  @REC-9 @STA-6 @LIM-1
  Scenario: When the date arrives the occurrence confirms itself
    When the day turns to 2026-03-20
    Then the 2026-03-20 occurrence of series "Netflix" is "confirmed"
    And I see the warning "The purchase 'Netflix' was confirmed; delete it if it didn't happen"
    And the 2026-04-20 occurrence of series "Netflix" is "planned"
    And the available limit of card "Purple" is R$ 4,944.10
    And there are no overdue entries

  @REC-9 @REC-4 @GER-11
  Scenario: A closed app confirms the subscriptions that passed, without making them overdue
    Given the projection horizon is 1 month
    And the recurring expense "Spotify" of R$ 21.90 on card "Purple", monthly, starting 2026-03-20, with no end
    And the series "Spotify" has 1 generated occurrence, from 2026-03-20 to 2026-03-20
    And the app has been closed since 2026-03-15
    When I open the app on 2026-05-25
    Then the occurrences of series "Spotify" are:
      | date       | status    | statement |
      | 2026-03-20 | confirmed | 2026-04   |
      | 2026-04-20 | confirmed | 2026-05   |
      | 2026-05-20 | confirmed | 2026-06   |
      | 2026-06-20 | planned   | 2026-07   |
    And no occurrence of series "Spotify" is "overdue"

  @REC-9 @GER-3 @edge
  Scenario: Automatic confirmation uses midnight in the user's time zone
    Given the user's time zone is "America/Manaus"
    When the clock reads 2026-03-20 00:30 in "America/Sao_Paulo" time
    Then the 2026-03-20 occurrence of series "Netflix" is "planned"
    When the clock reads 2026-03-20 00:00 in "America/Manaus" time
    Then the 2026-03-20 occurrence of series "Netflix" is "confirmed"

  @REC-9 @FAT-1 @edge
  Scenario: An occurrence on the closing day falls in the next statement
    When I create the recurring expense "Cloud" of R$ 10.00 on card "Purple", monthly, starting 2026-04-03, with no end
    Then the 2026-04-03 occurrence of series "Cloud" is in the 2026-05 statement of card "Purple"

  @REC-9 @REC-6
  Scenario: A price increase with all does not change the already confirmed charges
    Given today is 2026-04-25
    When I edit the 2026-05-20 occurrence of series "Netflix" with scope "all" to R$ 59.90
    Then the 2026-03-20 and 2026-04-20 occurrences of series "Netflix" are "confirmed" with amount R$ 55.90
    And the occurrences from 2026-05-20 to 2027-02-20 of series "Netflix" have amount R$ 59.90

  @REC-9 @REC-7
  Scenario: A deleted occurrence (paused month) is not charged when the date arrives
    Given the 2026-04-20 occurrence of series "Netflix" was deleted with scope "this only"
    When the day turns to 2026-04-20
    Then the series "Netflix" has no occurrence on 2026-04-20
    And the 2026-05 statement of card "Purple" does not have the subscription "Netflix"
    And the available limit of card "Purple" is R$ 4,944.10

  @REC-9 @REC-5 @REC-6
  Scenario: Cancelling the subscription ends the series and keeps the past charges
    Given today is 2026-04-25
    When I delete the 2026-05-20 occurrence of series "Netflix" with scope "this and following"
    Then the series "Netflix" has only the occurrences on 2026-03-20 and 2026-04-20, confirmed
    When the day turns to 2026-05-20
    Then no purchase "Netflix" is created

  @REC-9 @REC-3 @FAT-1 @CAR-2 @edge
  Scenario: Closing on day 31 can put two occurrences in one statement
    Given the card "Inter" with limit R$ 3,000.00, closing day 31, due day 10, payment account "Nubank" and start date 2026-01-01
    When I create the recurring expense "Magazine" of R$ 20.00 on card "Inter", monthly, starting 2026-03-30, with no end
    Then the occurrences of series "Magazine" are:
      | date       | statement |
      | 2026-03-30 | 2026-04   |
      | 2026-04-30 | 2026-06   |
      | 2026-05-30 | 2026-06   |
      | 2026-06-30 | 2026-08   |
      | 2026-07-30 | 2026-08   |
    And the 2026-05 statement of card "Inter" does not have the subscription "Magazine"
    And the 2026-07 statement of card "Inter" does not have the subscription "Magazine"
