Feature: Available limit
  Total debt = Σ outstanding of the statements, confirmed only. The rolled-over balance is not added again. Available = limit − debt.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @LIM-1
  Scenario: A single-payment purchase uses the limit
    When I add the purchase "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-10
    Then the total debt of card "Purple" is R$ 300.00
    And the available limit of card "Purple" is R$ 4,700.00

  @LIM-1 @PAR-6
  Scenario: An installment purchase uses the full amount right away and each payment frees it up
    Given the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    Then the available limit of card "Purple" is R$ 2,000.00
    When the day turns to 2026-04-08
    And I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08
    Then the total debt of card "Purple" is R$ 2,700.00
    And the available limit of card "Purple" is R$ 2,300.00

  @LIM-1 @EST-2
  Scenario: A refund frees up limit
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I add the refund "Sneakers" of R$ 100.00 to card "Purple" on 2026-03-15 linked to the purchase "Sneakers"
    Then the total debt of card "Purple" is R$ 200.00
    And the available limit of card "Purple" is R$ 4,800.00

  @LIM-3 @STA-6
  Scenario: A planned purchase does not use limit, but appears in the "available after planned entries"
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I add the purchase "Trip" of R$ 1,000.00 to card "Purple" on 2026-03-25
    Then the purchase "Trip" is "planned"
    And the available limit of card "Purple" is R$ 4,700.00
    And the available limit of card "Purple" after planned entries is R$ 3,700.00

  @LIM-3 @STA-6 @PAR-6
  Scenario: A planned purchase confirms itself on the day, with a warning, and starts using limit
    Given the purchase "Trip" of R$ 1,000.00 on card "Purple" on 2026-03-25
    When the day turns to 2026-03-24
    Then the purchase "Trip" is "planned"
    And the available limit of card "Purple" is R$ 5,000.00
    When the day turns to 2026-03-25
    Then the purchase "Trip" is "confirmed"
    And I see the warning "The purchase 'Trip' was confirmed; delete it if it didn't happen"
    And the available limit of card "Purple" is R$ 4,000.00
    And the 2026-04 statement of card "Purple" has total R$ 1,000.00 and outstanding R$ 1,000.00

  @LIM-3 @STA-6 @PAR-6
  Scenario: A planned installment purchase uses nothing until the purchase date
    When I add the purchase "Sofa" of R$ 2,400.00 to card "Purple" on 2026-04-01 in 6 installments
    Then all installments of the purchase "Sofa" are "planned"
    And the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Purple" after planned entries is R$ 2,600.00

  @LIM-2 @edge
  Scenario: A purchase exactly equal to the available limit does not warn
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I add the purchase "Laptop" of R$ 4,700.00 to card "Purple" on 2026-03-15
    Then I do not see the warning "This purchase exceeds the available limit"
    And the available limit of card "Purple" is R$ 0.00

  @LIM-2 @edge
  Scenario: A purchase above the available limit is allowed with a warning
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I add the purchase "Laptop" of R$ 4,700.01 to card "Purple" on 2026-03-15
    Then I see the warning "This purchase exceeds the available limit"
    And the purchase "Laptop" is "confirmed"
    And the available limit of card "Purple" is -R$ 0.01

  @LIM-2 @LIM-3 @edge
  Scenario: A planned purchase that exceeds the available limit after planned entries warns
    Given the purchase "Trip" of R$ 4,000.00 on card "Purple" on 2026-03-25
    When I add the purchase "Hotel" of R$ 1,500.00 to card "Purple" on 2026-03-28
    Then I see the warning "This purchase exceeds the available limit"
    And the available limit of card "Purple" after planned entries is -R$ 500.00
    And the available limit of card "Purple" is R$ 5,000.00

  @LIM-1 @FAT-9 @INV-5
  Scenario: Rolling over the statement does not increase the debt; added interest does
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When the day turns to 2026-04-11
    And I answer "I didn't pay" for the 2026-04 statement of card "Purple"
    Then the total debt of card "Purple" is R$ 300.00
    And the available limit of card "Purple" is R$ 4,700.00
    When I add the purchase "Revolving Interest" of R$ 45.00 to card "Purple" on 2026-04-11
    Then the total debt of card "Purple" is R$ 345.00
    And the available limit of card "Purple" is R$ 4,655.00

  @LIM-1 @EST-5 @PAR-6 @INV-4
  Scenario: Cancelling an installment purchase with an installment in a closed statement refunds and frees up the whole limit
    Given today is 2026-04-05
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I cancel the purchase "TV"
    Then the purchase "TV" is "cancelled"
    And the sum of the installments of the purchase "TV", counting the cancelled ones, is R$ 3,000.00
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-05 statement of card "Purple" has a refund linked to the purchase "TV" of R$ 300.00 on 2026-04-05
    And the 2026-05 statement of card "Purple" has total -R$ 300.00 and outstanding -R$ 300.00
    And the total debt of card "Purple" is R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00

  @LIM-1 @EST-5 @EST-4 @edge
  Scenario Outline: Cancelling settles the difference with already linked refunds
    Given today is 2026-04-05
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    And the refund "TV" of <refunded> on card "Purple" on 2026-04-04 linked to the purchase "TV"
    When I cancel the purchase "TV"
    Then <settlement>
    And the purchase "TV" costs R$ 0.00 net
    And the total debt of card "Purple" is R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00

    Examples:
      | refunded  | settlement                                                                                                        |
      | R$ 100.00 | the 2026-05 statement of card "Purple" has a refund linked to the purchase "TV" of R$ 200.00 on 2026-04-05        |
      | R$ 300.00 | the 2026-05 statement of card "Purple" has no cancellation settlement                                             |
      | R$ 500.00 | the 2026-05 statement of card "Purple" has the linked charge "Cancellation settlement" of R$ 200.00 on 2026-04-05 |

  @LIM-1 @EST-6
  Scenario: Closing the remaining installments does not generate a refund
    Given today is 2026-04-05
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I close the remaining installments of the purchase "TV"
    Then the 2026-05 statement of card "Purple" has no refund
    And the 2026-05 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the total debt of card "Purple" is R$ 300.00
    And the available limit of card "Purple" is R$ 4,700.00

  @LIM-1 @LIM-3 @STA-6 @EST-1 @edge
  Scenario: A refund with a future date is planned and only frees up limit on that date
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I add the refund "Sneakers" of R$ 300.00 to card "Purple" on 2026-03-20 linked to the purchase "Sneakers"
    Then the refund "Sneakers" is "planned"
    And the available limit of card "Purple" is R$ 4,700.00
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00
    And the 2026-04 statement of card "Purple" shows "- R$ 300.00 planned"
    When the day turns to 2026-03-20
    Then the refund "Sneakers" is "confirmed"
    And the available limit of card "Purple" is R$ 5,000.00
    And the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
