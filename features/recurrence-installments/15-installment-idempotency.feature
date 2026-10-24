Feature: Installments do not duplicate
  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments

  @GER-11 @INV-10 @INV-4
  Scenario: Generating the installments again changes nothing
    When installment generation runs again for the purchase "TV"
    Then the purchase "TV" has 10 installments of R$ 300.00, in the statements from 2026-04 to 2027-01
    And the sum of the installments of the purchase "TV" is R$ 3,000.00
    And the available limit of card "Purple" is R$ 2,000.00

  @GER-11 @INV-10 @integration
  Scenario: Two devices syncing the same purchase do not duplicate installments
    When the purchase "TV" is synced from device "iPhone" and device "Mac"
    Then the purchase "TV" has exactly 10 installments
    And each installment of the purchase "TV" has a unique identity "purchase + no.", from 1 to 10
