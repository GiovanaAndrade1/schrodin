Feature: A statement from the first purchase to the archived card
  Statement, limit, projection, actual balance and indicators have to move together
  at every step: closing, due date, rollover, interest, partial payments, credit and archiving.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 4,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months

  @integration @FAT-1 @FAT-3 @FAT-4 @FAT-5 @FAT-6 @FAT-9 @FAT-10 @FAT-11 @STA-4 @LIM-1 @TRF-8 @CAR-4 @IND-2 @PRJ-2 @INV-5
  Scenario: Purchase, closing, "I didn't pay", interest, partial payment, credit, withdrawal and archiving
    # purchase
    When I add the purchase "Laptop" of R$ 3,000.00 to card "Purple" on 2026-03-15
    Then the purchase "Laptop" is in the 2026-04 statement of card "Purple"
    And the available limit of card "Purple" is R$ 2,000.00
    And the actual balance of account "Nubank" is R$ 4,000.00
    And the projected balance of account "Nubank" on 2026-04-09 is R$ 4,000.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,000.00
    And the realized Outflows for 2026-03 are R$ 3,000.00
    # closing
    When the day turns to 2026-04-03
    Then the 2026-04 statement of card "Purple" is "closed" with total R$ 3,000.00 and outstanding R$ 3,000.00
    And the current open statement of card "Purple" is the 2026-05 one
    # due date without payment
    When the day turns to 2026-04-10
    Then the 2026-04 statement of card "Purple" is "closed"
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 1,000.00
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And I see the question "Did you pay?" for the 2026-04 statement of card "Purple"
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,000.00
    # I didn't pay: the remainder moves to another statement, the debt does not change
    When I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the 2026-04 statement of card "Purple" is "rolled over" with outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" is "open" with carried-over balance R$ 3,000.00 and total R$ 3,000.00
    And the available limit of card "Purple" is R$ 2,000.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 4,000.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 1,000.00
    And the realized Outflows for 2026-04 are R$ 0.00
    # interest: added by the user, counts as an Outflow and uses limit
    When I add the purchase "Interest and Fees" of R$ 450.00 to card "Purple" on 2026-04-11
    Then the purchase "Interest and Fees" is in the 2026-05 statement of card "Purple"
    And the 2026-05 statement of card "Purple" has total R$ 3,450.00
    And the available limit of card "Purple" is R$ 1,550.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 550.00
    And the realized Outflows for 2026-04 are R$ 450.00
    # partial payment
    When the day turns to 2026-05-08
    Then the 2026-05 statement of card "Purple" is "closed" with outstanding R$ 3,450.00
    When I pay R$ 2,000.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-08
    Then the 2026-05 statement of card "Purple" is "closed", "partially paid", with outstanding R$ 1,450.00
    And the actual balance of account "Nubank" is R$ 2,000.00
    And the available limit of card "Purple" is R$ 3,550.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 1,450.00 on 2026-05-10
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 550.00
    # overpayment on a closed statement: the credit carries over immediately
    When the day turns to 2026-05-10
    And I pay R$ 1,500.00 of the 2026-05 statement of card "Purple" from account "Nubank" on 2026-05-10
    Then the 2026-05 statement of card "Purple" is "paid" with outstanding R$ 0.00
    And the 2026-06 statement of card "Purple" has carried-over credit R$ 50.00 and total -R$ 50.00
    And the total debt of card "Purple" is -R$ 50.00
    And the available limit of card "Purple" is R$ 5,050.00, shown as "R$ 5,000.00 + R$ 50.00 of credit"
    And the actual balance of account "Nubank" is R$ 500.00
    And the projected balance of account "Nubank" on 2026-06-10 is R$ 500.00
    # archiving with credit is blocked
    When I archive the card "Purple"
    Then the operation is blocked with the message "The card has a credit of R$ 50.00. Withdraw the credit before archiving."
    # a withdrawal above the credit is blocked; an exact withdrawal zeroes the card
    When I withdraw R$ 60.00 of credit from card "Purple" to account "Nubank" on 2026-05-10
    Then the operation is blocked with the message "You can only withdraw up to R$ 50.00 of credit"
    When I withdraw R$ 50.00 of credit from card "Purple" to account "Nubank" on 2026-05-10
    Then the withdrawal goes into the 2026-06 statement of card "Purple", which ends up with total -R$ 50.00 and outstanding R$ 0.00
    And the actual balance of account "Nubank" is R$ 550.00
    And the consolidated actual balance went up by R$ 50.00
    And the total debt of card "Purple" is R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the sum of the outstanding amounts of the statements of card "Purple" is R$ 0.00
    And the realized Inflows for 2026-05 are R$ 0.00
    # archive
    When I archive the card "Purple"
    Then the card "Purple" is archived
    And the card "Purple" does not appear in the entry picker
    And the realized Outflows for 2026-03 are R$ 3,000.00
    And the realized Outflows for 2026-04 are R$ 450.00
    And the 2026-04 statement of card "Purple" is still in the history as "rolled over"
    And the 2026-05 statement of card "Purple" is still in the history as "paid"
    And the projected balance of account "Nubank" on 2027-05-10 is R$ 550.00

  @integration @FAT-9 @FAT-4 @FAT-6 @STA-4 @LIM-1 @IND-2 @GER-5
  Scenario: Undoing "I didn't pay" after adding interest and recording the payment that had been made
    Given the purchase "Laptop" of R$ 3,000.00 on card "Purple" on 2026-03-15
    And today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    And the purchase "Interest and Fees" of R$ 450.00 on card "Purple" on 2026-04-11
    When I undo the "I didn't pay" on the 2026-04 statement of card "Purple"
    Then the 2026-04 statement of card "Purple" is "overdue" with outstanding R$ 3,000.00
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 0.00 and total R$ 450.00
    And the total debt of card "Purple" is R$ 3,450.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,000.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 450.00 on 2026-05-10
    And I see the question "Did you pay?" for the 2026-04 statement of card "Purple"
    When I record the payment of R$ 3,000.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-09
    Then the 2026-04 statement of card "Purple" is "paid"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,000.00
    When I delete the purchase "Interest and Fees"
    Then the 2026-05 statement of card "Purple" is "open" with total R$ 0.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the realized Outflows for 2026-04 are R$ 0.00

  @integration @FAT-12 @FAT-9 @FAT-6 @LIM-1 @IND-2 @INV-5
  Scenario: A forgotten purchase dated in a rolled-over statement goes to the carried-over balance of the statement that received the rollover
    Given the purchase "Laptop" of R$ 3,000.00 on card "Purple" on 2026-03-15
    And today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    When I add the purchase "Uber" of R$ 40.00 to card "Purple" on 2026-03-20
    Then I see the warning "this changes a statement that has already closed"
    And the purchase "Uber" is in the 2026-04 statement of card "Purple"
    And the 2026-04 statement of card "Purple" is "rolled over" with total R$ 3,040.00 and outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 3,040.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 3,040.00 on 2026-05-10
    And the available limit of card "Purple" is R$ 1,960.00
    And the sum of the outstanding amounts of the statements of card "Purple" is R$ 3,040.00
    And the realized Outflows for 2026-03 are R$ 3,040.00

  @integration @FAT-12 @FAT-9 @GER-5 @LIM-1 @CON-4 @INV-5
  Scenario: Deleting the partial payment of an already rolled-over statement
    Given the purchase "Laptop" of R$ 3,000.00 on card "Purple" on 2026-03-15
    And the payment of R$ 1,000.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-09, confirmed
    And today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 2,000.00
    When I delete the payment of R$ 1,000.00 of the 2026-04 statement of card "Purple"
    Then the actual balance of account "Nubank" is R$ 4,000.00
    And the 2026-04 statement of card "Purple" is still "rolled over" with outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 3,000.00
    And the total debt of card "Purple" is R$ 3,000.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 3,000.00 on 2026-05-10

  @integration @TRF-4 @TRF-7 @FAT-7 @FAT-8 @FAT-6 @LIM-1 @IND-6
  Scenario: Paying the statement with money from Reserve is a withdrawal and eases the consolidated projection
    Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And the purchase "Laptop" of R$ 3,000.00 on card "Purple" on 2026-03-15
    When I pay R$ 1,000.00 of the 2026-04 statement of card "Purple" from account "Reserve" on 2026-03-15
    Then the actual balance of account "Reserve" is R$ 4,000.00
    And the consolidated actual balance is still R$ 4,000.00
    And the 2026-04 statement of card "Purple" is "open" with outstanding R$ 2,000.00
    And the available limit of card "Purple" is R$ 3,000.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 2,000.00 on 2026-04-10
    And the consolidated projected balance on 2026-04-10 is R$ 2,000.00
    And the realized Saved for 2026-03 is -R$ 1,000.00
    And the realized Outflows for 2026-03 are still R$ 3,000.00

  @integration @FAT-14 @FAT-8 @FAT-6 @FAT-10 @REC-1 @TRF-7 @PRJ-3
  Scenario: An autopay larger than the statement offsets the next one and becomes credit on confirmation
    Given the projection horizon is 2 months
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "Course" of R$ 400.00 on card "Purple" on 2026-04-10
    And the recurring transfer "Autopay" of R$ 500.00 from account "Nubank" to card "Purple", monthly, starting 2026-04-08, with no end
    Then the 2026-04-08 occurrence of series "Autopay" is linked to the 2026-04 statement of card "Purple"
    And the 2026-05-08 occurrence of series "Autopay" is linked to the 2026-05 statement of card "Purple"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-04-07 | R$ 4,000.00 |
      | 2026-04-08 | R$ 3,500.00 |
      | 2026-04-10 | R$ 3,500.00 |
      | 2026-05-08 | R$ 3,000.00 |
      | 2026-05-10 | R$ 3,000.00 |
    When the day turns to 2026-04-08
    And I confirm the 2026-04-08 occurrence of series "Autopay"
    Then the 2026-04 statement of card "Purple" is "paid" with outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over credit R$ 200.00
    And the total debt of card "Purple" is -R$ 200.00
    And the available limit of card "Purple" is R$ 5,200.00
    And the actual balance of account "Nubank" is R$ 3,500.00
