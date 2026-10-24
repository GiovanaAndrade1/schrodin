Feature: Changing a purchase or refund of a statement that has already closed

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10

  @FAT-12
  Scenario: Editing a purchase of an open statement does not warn
    When I edit the purchase "Sneakers" to R$ 350.00
    Then I do not see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" has total R$ 350.00 and outstanding R$ 350.00

  @FAT-12 @FAT-5
  Scenario: Editing a purchase of a closed unpaid statement warns and changes the amount
    Given today is 2026-03-05
    When I edit the purchase "Dinner" to R$ 250.00
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-03 statement of card "Purple" has total R$ 250.00 and outstanding R$ 250.00
    And the 2026-03 statement of card "Purple" is "closed"

  @FAT-12 @FAT-10
  Scenario: Reducing a purchase of a paid statement generates credit on the next one
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I edit the purchase "Dinner" to R$ 150.00
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-03 statement of card "Purple" is "paid"
    And the 2026-03 statement of card "Purple" has total R$ 150.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 50.00
    And the 2026-04 statement of card "Purple" has total R$ 250.00 and outstanding R$ 250.00

  @FAT-12 @FAT-5 @FAT-9 @FAT-6
  Scenario: Increasing a purchase of a paid, past-due statement leaves the difference overdue
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I edit the purchase "Dinner" to R$ 260.00
    Then the 2026-03 statement of card "Purple" has total R$ 260.00 and outstanding R$ 60.00
    And the 2026-03 statement of card "Purple" is "overdue"
    And I see the question "Did you pay?" for the 2026-03 statement of card "Purple"
    And the actual balance of account "Nubank" is R$ 800.00
    And the projected balance of account "Nubank" on 2026-03-15 is R$ 740.00

  @FAT-12 @FAT-5
  Scenario: Increasing a purchase of a statement paid before the due date makes it partially paid
    Given today is 2026-03-05
    And the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-05, confirmed
    When I edit the purchase "Dinner" to R$ 260.00
    Then the 2026-03 statement of card "Purple" is "closed"
    And the 2026-03 statement of card "Purple" appears as "partially paid"
    And the 2026-03 statement of card "Purple" has total R$ 260.00 and outstanding R$ 60.00

  @FAT-12 @FAT-10 @GER-5
  Scenario: Deleting a purchase of a paid statement becomes credit
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I delete the purchase "Dinner"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 200.00
    And the 2026-04 statement of card "Purple" has total R$ 100.00 and outstanding R$ 100.00

  @FAT-12 @FAT-1 @FAT-5
  Scenario: A forgotten purchase added with a date in an already paid statement
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I add the purchase "Uber" of R$ 40.00 to card "Purple" on 2026-02-25
    Then I see the warning "this changes a statement that has already closed"
    And the purchase "Uber" is in the 2026-03 statement of card "Purple"
    And the 2026-03 statement of card "Purple" has total R$ 240.00 and outstanding R$ 40.00
    And the 2026-03 statement of card "Purple" is "overdue"

  @FAT-12 @EST-1 @FAT-10
  Scenario: A refund dated in a paid statement warns and becomes credit
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I add the refund "Dinner" of R$ 50.00 to card "Purple" on 2026-02-25 linked to the purchase "Dinner"
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-03 statement of card "Purple" has total R$ 150.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 50.00
    And the 2026-04 statement of card "Purple" has total R$ 250.00 and outstanding R$ 250.00

  @FAT-12 @FAT-1 @FAT-10
  Scenario: Changing the date takes the purchase out of the paid statement and moves it to the open one
    Given the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I edit the purchase "Dinner" to date 2026-03-05
    Then I see the warning "this changes a statement that has already closed"
    And the purchase "Dinner" is in the 2026-04 statement of card "Purple"
    And the 2026-03 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the 2026-04 statement of card "Purple" has carried-over credit R$ 200.00
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00

  @FAT-12 @FAT-9 @edge
  Scenario: Editing a purchase of a rolled-over statement corrects the carried-over balance of the next one
    Given I answered "I didn't pay" for the 2026-03 statement of card "Purple"
    And the 2026-04 statement of card "Purple" has total R$ 500.00 and outstanding R$ 500.00
    When I edit the purchase "Dinner" to R$ 150.00
    Then I see the warning "this changes a statement that has already closed"
    And the 2026-03 statement of card "Purple" is "rolled over"
    And the 2026-04 statement of card "Purple" has carried-over balance R$ 150.00
    And the 2026-04 statement of card "Purple" has total R$ 450.00 and outstanding R$ 450.00
