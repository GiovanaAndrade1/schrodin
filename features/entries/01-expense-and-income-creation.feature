Feature: Expense and income creation

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And "Nubank" is the default account

  @LAN-1 @LAN-2 @CON-4
  Scenario: A confirmed account expense reduces the actual balance
    When I add the expense "Coffee" of R$ 8.50 to account "Nubank" on 2026-03-15
    Then the expense "Coffee" is "confirmed"
    And the actual balance of account "Nubank" is R$ 991.50

  @LAN-1 @LAN-3 @CON-4
  Scenario: A confirmed account income increases the actual balance
    When I add the income "Freelance" of R$ 1,500.00 to account "Nubank" on 2026-03-15
    Then the income "Freelance" is "confirmed"
    And the actual balance of account "Nubank" is R$ 2,500.00

  @LAN-2 @FAT-1 @LIM-1
  Scenario: A card expense goes to the statement and does not touch the account balance
    When I add the expense "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-15
    Then the purchase "Sneakers" is in the 2026-04 statement of card "Purple"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the available limit of card "Purple" is R$ 4,700.00

  @LAN-1 @CON-10
  Scenario: Date and account come prefilled with today and the default account
    When I open the new expense form
    Then the form date is 2026-03-15
    And the selected account is "Nubank"

  @LAN-2 @error
  Scenario: An expense with no account or card is blocked
    When I add the expense "Coffee" of R$ 8.50 with no account or card on 2026-03-15
    Then the operation is blocked with the message "Choose an account or a card"

  @LAN-3 @error
  Scenario: An income with no account is blocked
    When I add the income "Freelance" of R$ 1,500.00 with no account on 2026-03-15
    Then the operation is blocked with the message "Choose an account"

  @LAN-3 @EST-1 @error
  Scenario: Income does not go on a card: money coming back to the card is a refund
    When I add the income "Reimbursement" of R$ 50.00 to card "Purple" on 2026-03-15
    Then the operation is blocked with the message "Income only goes into an account. Money coming back to the card is a refund"

  @LAN-5
  Scenario: An entry with no tag is accepted and one with several tags keeps them all
    Given the tag "groceries"
    And the tag "leisure"
    When I add the expense "Market" of R$ 40.00 to account "Nubank" on 2026-03-15
    And I add the expense "Barbecue" of R$ 90.00 to account "Nubank" on 2026-03-15 with the tags "groceries, leisure"
    Then the expense "Market" has no tags
    And the expense "Barbecue" has the tags "groceries, leisure"

  @LAN-1 @edge
  Scenario: Two entries with the same title on the same day are allowed
    When I add the expense "Groceries" of R$ 50.00 to account "Nubank" on 2026-03-15
    And I add the expense "Groceries" of R$ 70.00 to account "Nubank" on 2026-03-15
    Then the account "Nubank" has 2 entries "Groceries" on 2026-03-15
    And the actual balance of account "Nubank" is R$ 880.00

  @AJU-1 @LAN-8
  Scenario: Adjustment does not appear as a type in the entry form
    When I open the new entry form
    Then the offered types are "expense, income, transfer, refund"

  @GER-6
  Scenario: An entry shows when it was created
    Given it is now 2026-03-15 10:42 in the user's time zone
    When I add the expense "Coffee" of R$ 8.50 to account "Nubank" on 2026-03-10
    Then the expense "Coffee" shows "Created on 2026-03-15 10:42"

  @GER-8 @GER-1 @edge
  Scenario: The balance can exceed the maximum amount of one entry by adding several
    When I add the income "Sale 1" of R$ 99,999,999.99 to account "Nubank" on 2026-03-15
    And I add the income "Sale 2" of R$ 99,999,999.99 to account "Nubank" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 200,000,999.98
