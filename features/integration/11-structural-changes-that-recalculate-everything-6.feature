Feature: Delete and undo

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 1,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 1 month
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20 with the tag "leisure"
    And the purchase "Groceries" of R$ 300.00 on card "Purple" on 2026-02-25 with the tag "groceries"
    And the payment of R$ 500.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    And the purchase "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-10 with the tag "leisure"

  @integration @GER-5 @FAT-12 @FAT-10 @LIM-1 @IND-2 @TAG-9 @PRJ-8 @INV-5
  Scenario: Deleting a purchase from a paid statement creates credit everywhere, and undo restores everything as it was
    Then the available limit of card "Purple" is R$ 4,900.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 2,400.00
    And the realized Outflows for 2026-02 are R$ 500.00
    When I delete the purchase "Dinner" and confirm
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-03 statement of card "Purple" is "paid" with total R$ 300.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 200.00 and total -R$ 100.00
    And the total debt of card "Purple" is -R$ 100.00
    And the available limit of card "Purple" is R$ 5,100.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 2,500.00
    And the realized Outflows for 2026-02 are R$ 300.00
    And the tag "leisure" does not appear in the realized tag report for 2026-02
    When I tap "Undo" after 2 seconds
    Then the purchase "Dinner" comes back with the same id and the same createdAt
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 0.00 and total R$ 100.00
    And the available limit of card "Purple" is R$ 4,900.00
    And the projected balance of account "Nubank" is the same as before the deletion on every day
    And the realized Outflows for 2026-02 are R$ 500.00

  @integration @GER-5 @TRF-2 @TRF-4 @TRF-7 @IND-6 @IND-7 @INV-2
  Scenario: Deleting and undoing the transfer to Reserve changes both sides and Saved
    Given the income "Salary" of R$ 4,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-05, confirmed
    And the actual balance of account "Nubank" is R$ 6,000.00
    And the realized savings rate for 2026-03 is 12.5%
    When I delete the transfer "Save" from the ledger of account "Reserve" and confirm
    Then the actual balance of account "Nubank" is R$ 6,500.00
    And the actual balance of account "Reserve" is R$ 1,000.00
    And the realized Saved for 2026-03 is R$ 0.00
    And the realized savings rate for 2026-03 is 0.0%
    When I tap "Undo" after 2 seconds
    Then the transfer "Save" comes back on both sides with the same id and the same createdAt
    And the actual balance of account "Nubank" is R$ 6,000.00
    And the actual balance of account "Reserve" is R$ 1,500.00
    And the realized Saved for 2026-03 is R$ 500.00

  @integration @CAR-8 @CON-7 @INV-7 @error
  Scenario Outline: Editing the card's start date
    When I change the start date of card "Purple" to <date>
    Then <result>

    Examples:
      | date       | result                                                                              |
      | 2025-12-01 | the start date of card "Purple" is 2025-12-01                                       |
      | 2026-02-21 | the operation is blocked listing "Dinner (2026-02-20)"                              |
      | 2026-03-01 | the operation is blocked listing "Dinner (2026-02-20)" and "Groceries (2026-02-25)" |
      | 2026-03-16 | the operation is blocked with the message "The start date can't be in the future"   |
