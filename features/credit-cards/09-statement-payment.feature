Feature: Statement payment
  A payment is a transfer from an account to the card, linked to a statement. It is not an expense.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 500.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-7 @CAR-3
  Scenario: The default statement is the oldest overdue one, with suggested amount and account
    Then the 2026-03 statement of card "Purple" is "overdue"
    When I open "Pay statement" on card "Purple"
    Then the suggested statement is the 2026-03 one
    And the suggested amount is R$ 200.00
    And the suggested account is "Nubank"

  @FAT-7 @TRF-3 @LIM-1
  Scenario: A payment is a transfer and does not count as an outflow
    When I pay R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the payment is a confirmed transfer from account "Nubank" to card "Purple"
    And the actual balance of account "Nubank" is R$ 800.00
    And the 2026-03 statement of card "Purple" is "paid"
    And the available limit of card "Purple" is R$ 4,700.00
    And the realized Outflows for 2026-03 are R$ 300.00

  @FAT-7 @FAT-13
  Scenario: With no pending closed statement, the default is the current open one
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-15, confirmed
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I open "Pay statement" on card "Purple"
    Then the suggested statement is the 2026-04 one
    And the suggested amount is R$ 600.00

  @FAT-7 @edge
  Scenario: With two overdue statements, the default is the oldest
    When the day turns to 2026-04-12
    Then the 2026-03 statement of card "Purple" is "overdue"
    And the 2026-04 statement of card "Purple" is "overdue"
    When I open "Pay statement" on card "Purple"
    Then the suggested statement is the 2026-03 one

  @FAT-7
  Scenario: A statement is paid from an account other than the default
    When I pay R$ 200.00 of the 2026-03 statement of card "Purple" from account "Wallet" on 2026-03-15
    Then the actual balance of account "Wallet" is R$ 300.00
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the 2026-03 statement of card "Purple" is "paid"

  @FAT-7 @TRF-4 @IND-6
  Scenario: Paying a statement from a "saving" account counts as a withdrawal
    Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 2,000.00 on 2026-01-01
    When I pay R$ 200.00 of the 2026-03 statement of card "Purple" from account "Reserve" on 2026-03-15
    Then the actual balance of account "Reserve" is R$ 1,800.00
    And the 2026-03 statement of card "Purple" is "paid"
    And the realized Saved for 2026-03 is -R$ 200.00

  @FAT-8 @FAT-7
  Scenario: The open statement is paid early even with a pending overdue one
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" is "open"
    And the 2026-03 statement of card "Purple" is "overdue"
    And the 2026-03 statement of card "Purple" has total R$ 200.00 and outstanding R$ 200.00

  @FAT-8 @STA-8 @error
  Scenario: A confirmed payment with a future date is blocked
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-20 as confirmed
    Then the operation is blocked with the message "A confirmed payment can't have a future date"

  @FAT-8 @STA-2 @LIM-1
  Scenario: A payment with a future date is created planned and does not free up limit
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08
    Then the payment of the 2026-04 statement of card "Purple" is "planned"
    And I do not see the warning "The payment is scheduled after the due date"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the available limit of card "Purple" is R$ 4,500.00

  @FAT-8 @edge
  Scenario: Scheduling a payment after the due date shows a warning
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-11
    Then I see the warning "The payment is scheduled after the due date"
    And the payment of the 2026-04 statement of card "Purple" is "planned"

  @FAT-8 @STA-5 @STA-8
  Scenario: Confirming a planned payment suggests today as the date
    Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned
    When I open "Confirm" on the payment of the 2026-04 statement of card "Purple"
    Then the suggested date is 2026-03-15
    When I confirm the payment of the 2026-04 statement of card "Purple" with amount R$ 300.00 on 2026-03-15
    Then the payment of the 2026-04 statement of card "Purple" is "confirmed"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the actual balance of account "Nubank" is R$ 700.00

  @FAT-7 @LAN-1 @GER-8 @error
  Scenario Outline: Invalid payment amount
    When I pay <amount> of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the operation is blocked with the message "<message>"

    Examples:
      | amount            | message                                |
      | R$ 0.00           | The amount must be greater than zero   |
      | R$ 100,000,000.00 | The maximum amount is R$ 99,999,999.99 |

  @FAT-7 @CON-3 @TRF-6 @error
  Scenario: A payment before the account's opening balance is blocked
    When I pay R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2025-12-31
    Then the operation is blocked with the message "The date can't be before the opening balance of account Nubank (2026-01-01)"

  @FAT-7 @TRF-1 @error
  Scenario: A payment from an archived account is blocked
    Given the account "Old" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    And the account "Old" is archived
    When I pay R$ 200.00 of the 2026-03 statement of card "Purple" from account "Old" on 2026-03-15
    Then the operation is blocked with the message "Account 'Old' is archived. Unarchive it to make changes"
