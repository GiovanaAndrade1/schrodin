Feature: Editing and deleting occurrences of a series
  In order to fix one occurrence or change the series from now on without rewriting the past

  Background:
    Given today is 2026-05-15
    And the account "Nubank" of kind "checking" with opening balance R$ 10,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the projection horizon is 12 months
    And the recurring expense "Rent" of R$ 2,000.00 in account "Nubank", monthly, starting 2026-03-10, for 12 occurrences
    And the 2026-03-10 and 2026-04-10 occurrences of series "Rent" are "confirmed"
    And the 2026-05-10 occurrence of series "Rent" is "overdue"

  @REC-5
  Scenario: Editing an occurrence asks for the scope
    When I open the editing of the 2026-06-10 occurrence of series "Rent"
    And I change the amount to R$ 2,100.00
    Then the app asks for the scope with the options "this only", "this and following" and "all"

  @REC-5 @edge
  Scenario: Editing a standalone entry does not ask for a scope
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-05-15, confirmed
    When I edit the expense "Groceries" to R$ 130.00
    Then the app does not ask for a scope
    And the expense "Groceries" has amount R$ 130.00

  @REC-5 @REC-7
  Scenario: This only changes one occurrence and detaches it
    When I edit the 2026-06-10 occurrence of series "Rent" with scope "this only" to R$ 2,100.00
    Then the 2026-06-10 occurrence of series "Rent" has amount R$ 2,100.00
    And the 2026-06-10 occurrence of series "Rent" is detached
    And the 2026-05-10 and 2026-07-10 occurrences of series "Rent" have amount R$ 2,000.00

  @REC-5 @REC-6
  Scenario: All changes overdue and future occurrences, never confirmed ones
    When I edit the 2026-06-10 occurrence of series "Rent" with scope "all" to R$ 2,100.00
    Then the occurrences of series "Rent" are:
      | date       | amount      | status    |
      | 2026-03-10 | R$ 2,000.00 | confirmed |
      | 2026-04-10 | R$ 2,000.00 | confirmed |
      | 2026-05-10 | R$ 2,100.00 | overdue   |
      | 2026-06-10 | R$ 2,100.00 | planned   |
      | 2027-02-10 | R$ 2,100.00 | planned   |
    And the actual balance of account "Nubank" is R$ 6,000.00

  @REC-6 @REC-7
  Scenario: All does not overwrite a detached occurrence
    Given the 2026-08-10 occurrence of series "Rent" was edited with scope "this only" to R$ 2,050.00
    When I edit the 2026-06-10 occurrence of series "Rent" with scope "all" to R$ 2,100.00
    Then the 2026-08-10 occurrence of series "Rent" has amount R$ 2,050.00
    And the 2026-07-10 and 2026-09-10 occurrences of series "Rent" have amount R$ 2,100.00

  @REC-6
  Scenario: All changes the account only of the unconfirmed occurrences
    When I edit the 2026-06-10 occurrence of series "Rent" with scope "all" to account "Wallet"
    Then the 2026-03-10 and 2026-04-10 occurrences of series "Rent" are in account "Nubank"
    And the 10 occurrences from 2026-05-10 to 2027-02-10 of series "Rent" are in account "Wallet"

  @REC-8 @REC-2 @REC-10
  Scenario: This and following splits the series and the new one inherits the remaining occurrences
    When I edit the 2026-07-10 occurrence of series "Rent" with scope "this and following" to R$ 2,200.00
    Then the original series "Rent" ends on 2026-06-10 with 4 occurrences, of R$ 2,000.00
    And a new series "Rent" starts on 2026-07-10 for 8 occurrences, of R$ 2,200.00, until 2027-02-10
    And the 2026-06-10 occurrence shows position "4/12"
    And the 2026-07-10 occurrence shows position "5/12"
    And the 2027-02-10 occurrence shows position "12/12"

  @REC-8 @REC-6
  Scenario: This and following from an overdue occurrence changes the overdue one
    When I edit the 2026-05-10 occurrence of series "Rent" with scope "this and following" to R$ 2,100.00
    Then the original series "Rent" ends on 2026-04-10 with 2 confirmed occurrences of R$ 2,000.00
    And a new series "Rent" starts on 2026-05-10 for 10 occurrences, of R$ 2,100.00
    And the 2026-05-10 occurrence of series "Rent" is "overdue" with amount R$ 2,100.00

  @REC-8 @REC-2
  Scenario: This and following on a series with no end generates a new series with no end
    Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-06-05, with no end
    When I edit the 2026-09-05 occurrence of series "Salary" with scope "this and following" to R$ 5,500.00
    Then the original series "Salary" ends on 2026-08-05 with 3 occurrences
    And a new series "Salary" starts on 2026-09-05, with no end, of R$ 5,500.00
    And the new series "Salary" has occurrences generated up to 2027-05-05

  @REC-8 @REC-7
  Scenario: This and following preserves a detached occurrence after the split point
    Given the 2026-08-10 occurrence of series "Rent" was edited with scope "this only" to R$ 2,050.00
    When I edit the 2026-07-10 occurrence of series "Rent" with scope "this and following" to R$ 2,200.00
    Then the 2026-08-10 occurrence belongs to the new series "Rent" and has amount R$ 2,050.00
    And the 2026-09-10 occurrence of the new series "Rent" has amount R$ 2,200.00

  @REC-6 @REC-8 @edge
  Scenario: This and following from a confirmed occurrence does not change the confirmed one
    When I edit the 2026-04-10 occurrence of series "Rent" with scope "this and following" to R$ 2,100.00
    Then I see the warning "Confirmed occurrences were not changed. To fix one of them, use 'this only'."
    And the 2026-04-10 occurrence of series "Rent" is "confirmed" with amount R$ 2,000.00
    And the 2026-05-10 occurrence of series "Rent" has amount R$ 2,100.00
    And the original series "Rent" ends on 2026-03-10 with 1 occurrence

  @REC-6 @REC-8 @STA-9 @edge
  Scenario: A confirmed occurrence after the split point moves to the new series unchanged
    Given I unconfirmed the 2026-04-10 occurrence of series "Rent"
    And I confirmed the 2026-05-10 occurrence of series "Rent" with amount R$ 2,000.00 on 2026-05-10
    When I edit the 2026-04-10 occurrence of series "Rent" with scope "this and following" to R$ 2,100.00
    Then the original series "Rent" ends on 2026-03-10 with 1 occurrence
    And the new series "Rent" has 11 occurrences, from 2026-04-10 to 2027-02-10
    And the occurrences of the new series "Rent" are:
      | date       | amount      | status    | position |
      | 2026-04-10 | R$ 2,100.00 | overdue   | 12-02    |
      | 2026-05-10 | R$ 2,000.00 | confirmed | 3/12     |
      | 2026-06-10 | R$ 2,100.00 | planned   | 4/12     |
    And the 2026-03-10 occurrence of the original series shows position "1/12"

  @REC-8 @edge
  Scenario: This and following on the first occurrence does not leave an empty series
    Given the recurring expense "Insurance" of R$ 150.00 in account "Nubank", monthly, starting 2026-06-01, for 6 occurrences
    When I edit the 2026-06-01 occurrence of series "Insurance" with scope "this and following" to R$ 160.00
    Then there is only one series "Insurance"
    And the series "Insurance" has 6 generated occurrences, from 2026-06-01 to 2026-11-01, all of R$ 160.00
    And the 2026-06-01 occurrence of series "Insurance" shows position "1/6"

  @REC-3 @REC-6 @GER-11 @INV-10 @STA-3 @edge
  Scenario: All changing the anchor day moves the overdue occurrence to today without duplicating
    When I edit the 2026-06-10 occurrence of series "Rent" with scope "all" to day 15
    And occurrence generation runs again
    Then the series "Rent" has occurrences on 2026-03-10, 2026-04-10, 2026-05-15, 2026-06-15, 2026-07-15
    And the 2026-05-15 occurrence of series "Rent" is "planned"
    And the last occurrence of series "Rent" is 2027-02-15
    And the series "Rent" has 12 occurrences, with identities "series + no." from 1 to 12
    And the series "Rent" has no occurrence on 2026-06-10

  @REC-3 @REC-8
  Scenario: This and following with a new date changes the weekday of the weekly series
    Given the recurring expense "Soccer" of R$ 30.00 in account "Nubank", weekly, starting 2026-05-17, with no end
    When I edit the 2026-05-31 occurrence of series "Soccer" with scope "this and following" to date 2026-06-01
    Then the original series "Soccer" has occurrences on 2026-05-17 and 2026-05-24
    And the new series "Soccer" has occurrences on 2026-06-01, 2026-06-08, 2026-06-15

  @REC-5 @REC-7 @REC-10
  Scenario: Deleting this only creates an exception with no replacement and keeps the positions
    When I delete the 2026-09-10 occurrence of series "Rent" with scope "this only"
    Then the series "Rent" has no occurrence on 2026-09-10
    And the series "Rent" has 11 occurrences, from 2026-03-10 to 2027-02-10
    And the 2026-10-10 occurrence of series "Rent" shows position "8/12"

  @REC-5 @REC-8 @REC-10 @REC-11
  Scenario: Deleting this and following ends the series at the previous occurrence
    When I delete the 2026-10-10 occurrence of series "Rent" with scope "this and following"
    Then the series "Rent" ends on 2026-09-10 with 7 occurrences
    And the series "Rent" has no occurrences after 2026-09-10
    And the 2026-09-10 occurrence of series "Rent" shows position "7/7"

  @REC-5 @REC-6 @REC-7
  Scenario: Deleting all removes planned, overdue and detached occurrences and keeps the confirmed ones
    Given the 2026-08-10 occurrence of series "Rent" was edited with scope "this only" to R$ 2,050.00
    When I delete the 2026-06-10 occurrence of series "Rent" with scope "all"
    Then the series "Rent" has only the occurrences on 2026-03-10 and 2026-04-10, confirmed
    And the series "Rent" is ended
    And the actual balance of account "Nubank" is R$ 6,000.00
    And there are no overdue entries
