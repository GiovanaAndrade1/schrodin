Feature: Past-due statement with no payment
  A statement past its due date with outstanding > 0 becomes overdue and the app asks "Did you pay?".

  Background:
    Given today is 2026-04-10
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-04-05

  @FAT-9 @FAT-5 @edge
  Scenario: The question appears only on the day after the due date
    Then the 2026-04 statement of card "Purple" is "closed"
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And I see the question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-9 @FAT-8 @FAT-6
  Scenario: A planned payment that covers the outstanding amount avoids the question
    Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-12, planned
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-04-12 is R$ 700.00

  @FAT-9 @FAT-8 @edge
  Scenario: A planned payment that does not cover the outstanding amount does not avoid the question
    Given the payment of R$ 200.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-12, planned
    When the day turns to 2026-04-11
    Then I see the question "Did you pay?" for the 2026-04 statement of card "Purple"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 100.00 on 2026-04-11

  @FAT-9 @FAT-8
  Scenario: "Record payment" with the actual date, before the due date
    Given today is 2026-04-11
    When I answer "record payment" for the 2026-04 statement of card "Purple" with R$ 300.00 from account "Nubank" on 2026-04-09
    Then the 2026-04 statement of card "Purple" is "paid"
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"
    And the actual balance of account "Nubank" is R$ 700.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 700.00

  @FAT-9 @FAT-8 @error
  Scenario: "Record payment" does not accept a future date
    Given today is 2026-04-11
    When I answer "record payment" for the 2026-04 statement of card "Purple" with R$ 300.00 from account "Nubank" on 2026-04-12
    Then the operation is blocked with the message "A confirmed payment can't have a future date"

  @FAT-9 @FAT-4 @FAT-5 @FAT-6
  Scenario: "I didn't pay" rolls the remainder over to the next statement
    Given today is 2026-04-11
    When I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the 2026-04 statement of card "Purple" is "rolled over"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 300.00
    And the 2026-05 statement of card "Purple" has total R$ 400.00 and outstanding R$ 400.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2026-04-11 is R$ 1,000.00
    And the projected balance of account "Nubank" on 2026-05-10 is R$ 600.00
    And I see the suggestion "Add revolving interest and fees as an expense on the card"

  @FAT-9 @FAT-5
  Scenario: A partial payment and then "I didn't pay" rolls over only the remainder
    Given the payment of R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed
    When the day turns to 2026-04-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 200.00
    When I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the 2026-05 statement of card "Purple" has carried-over balance R$ 200.00
    And the 2026-05 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00

  @FAT-9 @FAT-1
  Scenario: Interest is added by the user as an expense on the card, the app does not calculate it
    Given today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the 2026-05 statement of card "Purple" has no interest entry created by the app
    When I add the purchase "Revolving Interest" of R$ 45.00 to card "Purple" on 2026-04-11
    Then the purchase "Revolving Interest" is in the 2026-05 statement of card "Purple"
    And the 2026-05 statement of card "Purple" has total R$ 445.00 and outstanding R$ 445.00

  @FAT-9 @error
  Scenario: "I didn't pay" is not offered before the due date
    Then the 2026-04 statement of card "Purple" is "closed"
    When I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the operation is blocked with the message "The statement isn't due yet"

  @FAT-9 @FAT-6 @STA-4
  Scenario: With no answer, overdue statements pile up in today's balance
    When the day turns to 2026-05-11
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the 2026-05 statement of card "Purple" is "overdue"
    And the projected balance of account "Nubank" on 2026-05-11 is R$ 600.00

  @FAT-9 @FAT-4 @edge
  Scenario: The rollover goes to the immediately following statement, even if already past due
    Given today is 2026-05-11
    When I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the 2026-05 statement of card "Purple" has carried-over balance R$ 300.00
    And the 2026-05 statement of card "Purple" has total R$ 400.00 and outstanding R$ 400.00
    And the 2026-05 statement of card "Purple" is "overdue"
    And the 2026-06 statement of card "Purple" has carried-over balance R$ 0.00
    And the projected balance of account "Nubank" on 2026-05-11 is R$ 600.00

  @FAT-9
  Scenario: "I didn't pay" is undone while the next statement is open
    Given today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    When I undo the "I didn't pay" on the 2026-04 statement of card "Purple"
    Then the 2026-04 statement of card "Purple" is "overdue"
    And the 2026-05 statement of card "Purple" has carried-over balance R$ 0.00
    And I see the question "Did you pay?" for the 2026-04 statement of card "Purple"

  @FAT-9 @error @edge
  Scenario: "I didn't pay" cannot be undone after the next statement has closed
    Given today is 2026-04-11
    And I answered "I didn't pay" for the 2026-04 statement of card "Purple"
    When the day turns to 2026-05-03
    And I undo the "I didn't pay" on the 2026-04 statement of card "Purple"
    Then the operation is blocked with the message "The statement that received the balance has already closed. Pay the 2026-05 statement."
    And the 2026-04 statement of card "Purple" is "rolled over"
