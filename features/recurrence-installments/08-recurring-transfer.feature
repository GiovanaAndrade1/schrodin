Feature: Recurring transfer
  In order to "save R$ 500 every month"

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months

  @REC-1 @TRF-2 @TRF-5
  Scenario: A recurring transfer generates both sides as planned
    When I create the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-04-05, for 3 occurrences
    Then the series "Save" has 3 generated occurrences, from 2026-04-05 to 2026-06-05
    And each occurrence of series "Save" leaves "Nubank" and enters "Reserve", "planned" on both sides

  @REC-1 @TRF-6 @CON-3 @error
  Scenario: A recurring transfer respects the destination's opening balance
    Given the account "Piggy Bank" of kind "savings" with opening balance R$ 0.00 on 2026-04-10
    When I create the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Piggy Bank", monthly, starting 2026-04-05, with no end
    Then the operation is blocked with the message "The date can't be before the opening balance of account Piggy Bank (2026-04-10)"

  @REC-1 @TRF-1 @error
  Scenario: A recurring transfer to the same account is rejected
    When I create the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Nubank", monthly, starting 2026-04-05, with no end
    Then the operation is blocked with the message "Source and destination must be different"

  @REC-5 @REC-6 @TRF-2
  Scenario: Editing all changes both sides of each occurrence
    Given the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-04-05, for 3 occurrences
    When I edit the 2026-05-05 occurrence of series "Save" with scope "all" to R$ 600.00
    Then each occurrence of series "Save" takes R$ 600.00 out of "Nubank" and puts R$ 600.00 into "Reserve"

  @TRF-5 @INV-2 @REC-4
  Scenario: Confirming an occurrence confirms both sides
    Given the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-04-05, for 3 occurrences
    And today is 2026-04-05
    When I confirm the 2026-04-05 occurrence of series "Save"
    Then the actual balance of account "Nubank" is R$ 500.00
    And the actual balance of account "Reserve" is R$ 500.00

  @REC-7 @TRF-2
  Scenario: Deleting this only removes both sides
    Given the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-04-05, for 3 occurrences
    When I delete the 2026-05-05 occurrence of series "Save" with scope "this only"
    Then neither "Nubank" nor "Reserve" has an entry "Save" on 2026-05-05
    And the series "Save" has 2 occurrences, on 2026-04-05 and 2026-06-05

  @REC-1 @FAT-14 @FAT-7
  Scenario: A recurring statement payment links each occurrence to the month's statement
    When I create the recurring transfer "Autopay" of R$ 300.00 from account "Nubank" to card "Purple", monthly, starting 2026-04-10, for 3 occurrences
    Then the 2026-04-10 occurrence of series "Autopay" is a planned payment of the 2026-04 statement of card "Purple"
    And the 2026-05-10 occurrence of series "Autopay" is a planned payment of the 2026-05 statement of card "Purple"
    And the 2026-06-10 occurrence of series "Autopay" is a planned payment of the 2026-06 statement of card "Purple"
