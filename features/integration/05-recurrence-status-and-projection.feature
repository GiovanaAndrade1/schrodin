Feature: Recurring series, overdue entries and the horizon changing the projection

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-02-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-02-01
    And the daily amount is R$ 50.00 since 2026-02-01
    And the projection horizon is 3 months
    And the recurring income "Salary" of R$ 6,000.00 in account "Nubank", monthly, starting 2026-02-17, with no end
    And the recurring expense "Rent" of R$ 1,500.00 in account "Nubank", monthly, starting 2026-02-19, with no end
    And the recurring expense "Netflix" of R$ 55.90 on card "Purple", monthly, starting 2026-02-18, with no end
    And the 2026-02 occurrences of "Salary" and "Rent", confirmed
    And the payment of R$ 55.90 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the actual balance of account "Nubank" is R$ 5,444.10

  @integration @REC-4 @REC-9 @STA-3 @STA-4 @STA-5 @STA-6 @STA-7 @REC-5 @REC-6 @REC-7 @REC-8 @REC-12 @GER-11 @GER-12 @PRJ-2 @PRJ-3 @PRJ-7 @IND-1 @IND-11 @LIM-1 @INV-10
  Scenario: App closed for 5 days, confirming with another amount, "this and following" and a reduced horizon
    Given the app was closed from 2026-03-15 to 2026-03-20
    When I open the app on 2026-03-20
    Then the 2026-03-17 occurrence of series "Salary" is "overdue"
    And the 2026-03-19 occurrence of series "Rent" is "overdue"
    And the 2026-03-18 occurrence of series "Netflix" is "confirmed"
    And the purchase "Netflix" from 2026-03-18 is in the 2026-04 statement of card "Purple"
    And I see the warning "The purchase 'Netflix' was confirmed; delete it if it didn't happen"
    And the overdue badge shows 2
    And the available limit of card "Purple" is R$ 4,944.10
    And the series generated the planned occurrences on 2026-06-17 ("Salary"), 2026-06-18 ("Netflix") and 2026-06-19 ("Rent")
    And there is no daily reserve from 2026-03-15 to 2026-03-19
    And the actual balance of account "Nubank" is R$ 5,444.10
    And the consolidated projected balance on 2026-03-20 is R$ 9,894.10
    # confirming with a different amount: this only
    When I confirm the 2026-03-17 occurrence of series "Salary" with amount R$ 6,200.00 on 2026-03-17
    Then the actual balance of account "Nubank" is R$ 11,644.10
    And the consolidated projected balance on 2026-03-20 is R$ 10,094.10
    And the realized Inflows for 2026-03 are R$ 6,200.00
    And the 2026-04-17 occurrence of series "Salary" is still planned with R$ 6,000.00
    And the overdue badge shows 1
    # splitting the series from an overdue occurrence
    When I edit the 2026-03-19 occurrence of series "Rent" with scope "this and following" to R$ 1,600.00
    Then the original series "Rent" ends at the 2026-02-19 occurrence, which is still confirmed with R$ 1,500.00
    And the new series "Rent" starts on 2026-03-19 with R$ 1,600.00
    And the 2026-03-19 occurrence of the new series "Rent" is "overdue", now with R$ 1,600.00
    And the forecast Outflows for 2026-03 are R$ 1,655.90
    And the realized Outflows for 2026-03 are R$ 55.90
    And the consolidated projected balance is:
      | date       | balance      |
      | 2026-03-20 | R$ 9,994.10  |
      | 2026-04-10 | R$ 8,888.20  |
      | 2026-04-16 | R$ 8,588.20  |
      | 2026-04-17 | R$ 14,538.20 |
      | 2026-04-19 | R$ 12,838.20 |
      | 2026-05-10 | R$ 11,732.30 |
      | 2026-06-20 | R$ 18,426.40 |
    And the lowest future balance is R$ 8,588.20 on 2026-04-16
    # reducing the horizon
    When I change the projection horizon to 1 month
    Then the horizon end is 2026-04-20
    And the planned occurrences on 2026-05-17 and 2026-06-17 ("Salary"), 2026-05-18 and 2026-06-18 ("Netflix") and 2026-05-19 and 2026-06-19 ("Rent") were removed
    And the overdue one on 2026-03-19 and the planned ones on 2026-04-17, 2026-04-18 and 2026-04-19 still exist
    And the consolidated projected balance on 2026-04-20 is R$ 12,788.20
    And there is no projected balance on 2026-04-21
    And the lowest future balance is R$ 8,588.20 on 2026-04-16
    # restoring the horizon regenerates without duplicating
    When I change the projection horizon to 3 months
    Then the removed occurrences come back with the same identities (series + occurrence number)
    And the 2026-05-17 occurrence of series "Salary" is planned with R$ 6,000.00
    And the 2026-05-19 occurrence of the new series "Rent" is planned with R$ 1,600.00
    And there is a single 2026-03-17 occurrence of series "Salary", confirmed with R$ 6,200.00
    And the consolidated projected balance on 2026-06-20 is R$ 18,426.40

  @integration @TRF-4 @TRF-5 @TRF-7 @STA-4 @STA-7 @IND-6 @IND-7 @IND-11 @PRJ-5
  Scenario: An overdue recurring "Save" counts today in both accounts and only enters realized Saved on confirmation
    Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-02-01
    And the daily amount changes to R$ 0.00 from 2026-03-15
    And the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-03-21, with no end
    Then the forecast Saved for 2026-03 is R$ 500.00
    And the realized Saved for 2026-03 is R$ 0.00
    And the forecast savings rate for 2026-03 is 8.3%
    And the realized savings rate for 2026-03 is not shown
    And the consolidated projected balance on 2026-03-20 is R$ 9,944.10
    And the consolidated projected balance on 2026-03-21 is R$ 9,444.10
    And the projected balance of account "Reserve" on 2026-03-21 is R$ 500.00
    When the day turns to 2026-03-22
    Then the 2026-03-21 occurrence of series "Save" is "overdue" on both sides
    And the overdue badge shows 3
    And the actual balance of account "Reserve" is R$ 0.00
    And the projected balance of account "Reserve" on 2026-03-22 is R$ 500.00
    And the consolidated projected balance on 2026-03-22 is R$ 9,444.10
    When I confirm the 2026-03-21 occurrence of series "Save" with amount R$ 500.00 on 2026-03-21
    Then the actual balance of account "Nubank" is R$ 4,944.10
    And the actual balance of account "Reserve" is R$ 500.00
    And the consolidated projected balance on 2026-03-22 is R$ 9,444.10
    And the realized Saved for 2026-03 is R$ 500.00
    And the overdue badge shows 2
