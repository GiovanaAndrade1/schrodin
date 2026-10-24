Feature: Refund and cancellation of an installment purchase across statement, limit, indicator, tag and projection

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 5,000.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months
    And the purchase "Fridge" of R$ 3,000.00 on card "Purple" on 2026-01-20 in 10 installments with the tag "household"
    And the payment of R$ 300.00 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed
    And the payment of R$ 300.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10, confirmed
    And the purchase "Groceries" of R$ 100.00 on card "Purple" on 2026-03-12 with the tag "groceries"

  @integration @PAR-1 @LIM-1 @FAT-6 @IND-11 @TAG-9
  Scenario: State before any refund
    Then the installments of the purchase "Fridge" are:
      | k  | amount    | statement | accrual |
      | 1  | R$ 300.00 | 2026-02   | 2026-01 |
      | 2  | R$ 300.00 | 2026-03   | 2026-02 |
      | 3  | R$ 300.00 | 2026-04   | 2026-03 |
      | 10 | R$ 300.00 | 2026-11   | 2026-10 |
    And the actual balance of account "Nubank" is R$ 4,400.00
    And the total debt of card "Purple" is R$ 2,500.00
    And the 2026-04 statement of card "Purple" has total R$ 400.00
    And the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-04-10 | R$ 4,000.00 |
      | 2026-05-10 | R$ 3,700.00 |
      | 2026-11-10 | R$ 1,900.00 |
    And the realized Outflows for 2026-03 are R$ 100.00
    And the forecast Outflows for 2026-03 are R$ 400.00

  @integration @EST-5 @EST-1 @EST-2 @EST-3 @FAT-4 @FAT-6 @FAT-10 @LIM-1 @IND-2 @IND-8 @TAG-9 @INV-4 @INV-5
  Scenario: Cancelling the purchase changes everything at the same time
    When I cancel the purchase "Fridge"
    Then the purchase "Fridge" is "cancelled"
    And installments 3 to 10 of the purchase "Fridge" are "cancelled", are still recorded and leave the statement, the limit and the indicators
    And the sum of the installments of the purchase "Fridge", counting the cancelled ones, is R$ 3,000.00
    And the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 600.00 on 2026-03-15
    And the refund "Fridge" has the tag "household"
    And the 2026-04 statement of card "Purple" is "open" with total -R$ 500.00
    And the total debt of card "Purple" is -R$ 500.00
    And the available limit of card "Purple" is R$ 5,500.00, shown as "R$ 5,000.00 + R$ 500.00 of credit"
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    And the projected balance of account "Nubank" on 2027-03-15 is R$ 4,400.00
    And the lowest future balance of account "Nubank" is R$ 4,400.00 on 2026-03-15
    And the realized Outflows for 2026-01 are R$ 300.00
    And the realized Outflows for 2026-02 are R$ 300.00
    And the realized Outflows for 2026-03 are -R$ 500.00
    And the forecast Outflows for 2026-03 are -R$ 500.00
    And the forecast Outflows for 2026-04 are R$ 0.00
    And the forecast tag report for 2026-03 shows:
      | tag       | expenses   | income  |
      | household | -R$ 600.00 | R$ 0.00 |
      | groceries | R$ 100.00  | R$ 0.00 |
    And the tag "household" does not appear in the forecast tag report for 2026-04
    And the actual balance of account "Nubank" is R$ 4,400.00
    When the day turns to 2026-04-01
    Then the cost of living is R$ 33.33
    When the day turns to 2026-04-03
    Then the 2026-05 statement of card "Purple" has carried-over credit R$ 500.00
    And the 2026-04 statement of card "Purple" has outstanding R$ 0.00

  @integration @EST-5 @EST-6 @LIM-1 @FAT-6 @IND-2 @TAG-9
  Scenario Outline: Cancel purchase × close remaining installments
    When I <action> the purchase "Fridge"
    Then <refund>
    And the 2026-04 statement of card "Purple" has total <April>
    And the total debt of card "Purple" is <debt>
    And the available limit of card "Purple" is <available>
    And the derived outflow of the 2026-04 statement of card "Purple" is <outflow April> on 2026-04-10
    And the forecast Outflows for 2026-03 are <outflows March>
    And <household March>

    Examples:
      | action                              | refund                                                                                                         | April      | debt       | available   | outflow April | outflows March | household March                                                                        |
      | cancel                              | the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 600.00 on 2026-03-15 | -R$ 500.00 | -R$ 500.00 | R$ 5,500.00 | R$ 0.00       | -R$ 500.00     | the forecast tag report for 2026-03 shows the tag "household" with expenses -R$ 600.00 |
      | close the remaining installments of | there is no refund linked to the purchase "Fridge"                                                             | R$ 100.00  | R$ 100.00  | R$ 4,900.00 | R$ 100.00     | R$ 100.00      | the tag "household" does not appear in the forecast tag report for 2026-03             |

  @integration @EST-1 @EST-3 @EST-4 @EST-5 @FAT-6 @FAT-10 @LIM-1 @IND-2 @TAG-9
  Scenario: A negotiated discount as a partial refund and then cancellation
    When I add the refund "Fridge Discount" of R$ 450.00 to card "Purple" on 2026-03-15 linked to the purchase "Fridge"
    Then the refund "Fridge Discount" has the tag "household"
    And the installments of the purchase "Fridge" are still R$ 300.00
    And the 2026-04 statement of card "Purple" has total -R$ 50.00
    And the total debt of card "Purple" is R$ 2,050.00
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 0.00
    # offset by the R$ 50.00 credit of the open 2026-04 statement (FAT-10)
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 250.00 on 2026-05-10
    And the realized Outflows for 2026-03 are -R$ 350.00
    And the forecast Outflows for 2026-03 are -R$ 50.00
    And the forecast tag report for 2026-03 shows the tag "household" with expenses -R$ 150.00
    When I cancel the purchase "Fridge"
    Then the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 150.00 on 2026-03-15
    And the sum of the refunds linked to the purchase "Fridge" is R$ 600.00
    And the 2026-04 statement of card "Purple" has total -R$ 500.00
    And the total debt of card "Purple" is -R$ 500.00

  @integration @EST-5 @EST-4 @EST-3 @FAT-4 @LIM-1 @IND-2 @TAG-9 @INV-4 @INV-5
  Scenario: Cancelling after a refund larger than what was already charged generates "Cancellation settlement"
    Given the refund "Fridge Discount" of R$ 900.00 on card "Purple" on 2026-03-15 linked to the purchase "Fridge"
    And the 2026-04 statement of card "Purple" has total -R$ 500.00
    And the total debt of card "Purple" is R$ 1,600.00
    When I cancel the purchase "Fridge"
    Then no new refund is generated
    And the 2026-04 statement of card "Purple" has the linked charge "Cancellation settlement" of R$ 300.00 on 2026-03-15
    And the purchase "Fridge" costs R$ 0.00 net: R$ 600.00 charged − R$ 900.00 refunded + R$ 300.00 of settlement
    And the sum of the installments of the purchase "Fridge", counting the cancelled ones, is R$ 3,000.00
    And the 2026-04 statement of card "Purple" has total -R$ 500.00
    And the total debt of card "Purple" is -R$ 500.00
    And the available limit of card "Purple" is R$ 5,500.00
    And the realized Outflows for 2026-03 are -R$ 500.00
    And the forecast tag report for 2026-03 shows the tag "household" with expenses -R$ 600.00
    And the projected balance of account "Nubank" on 2027-03-15 is R$ 4,400.00

  @integration @PAR-5 @EST-1 @EST-3 @FAT-6 @LIM-1 @IND-2 @TAG-9 @PRJ-3
  Scenario: Prepaying the last two installments with a discount
    When I prepay the last 2 installments of the purchase "Fridge" with a discount of R$ 60.00
    Then installments 9 and 10 of the purchase "Fridge" are in the 2026-04 statement
    And installment 9 still has accrual month 2026-09 and installment 10 accrual month 2026-10
    And the 2026-04 statement of card "Purple" has a refund linked to the purchase "Fridge" of R$ 60.00 on 2026-03-15
    And the 2026-04 statement of card "Purple" has total R$ 940.00
    And the 2026-10 and 2026-11 statements of card "Purple" have no installment at all
    And the total debt of card "Purple" is R$ 2,440.00
    And the projected balance of account "Nubank" is:
      | date       | balance     |
      | 2026-04-10 | R$ 3,460.00 |
      | 2026-09-10 | R$ 1,960.00 |
      | 2026-11-10 | R$ 1,960.00 |
    And the forecast Outflows for 2026-03 are R$ 340.00
    And the forecast Outflows for 2026-09 are R$ 300.00
    And the forecast tag report for 2026-03 shows the tag "household" with expenses R$ 240.00
