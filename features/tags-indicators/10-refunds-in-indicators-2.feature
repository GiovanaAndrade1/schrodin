Feature: Refund in a different month, cancellation and closing of installments

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the tag "clothing"

  @EST-3 @IND-2 @IND-5 @TAG-9 @edge
  Scenario: A refund in a later month reduces the refund's month and can make Outflows negative
    Given the purchase "Jacket" of R$ 400.00 on card "Purple" on 2026-02-20 with the tag "clothing"
    And the refund "Jacket" of R$ 400.00 on card "Purple" on 2026-03-02 linked to the purchase "Jacket"
    Then the realized Outflows for 2026-02 are R$ 400.00
    And the realized Outflows for 2026-03 are -R$ 400.00
    And the realized Performance for 2026-03 is R$ 400.00
    And the realized Outflows list for 2026-03 shows "Jacket (refund)" with -R$ 400.00
    And the realized tag report for 2026-03 shows:
      | tag      | expenses   | income  |
      | clothing | -R$ 400.00 | R$ 0.00 |

  @EST-5 @EST-3 @IND-2 @INV-4
  Scenario: Cancelling an installment purchase zeroes the net effect on the indicators
    Given the purchase "Course" of R$ 1,200.00 on card "Purple" on 2026-01-10 in 3 installments
    And the installments of the purchase "Course" are in the statements 2026-02 (closed), 2026-03 (closed) and 2026-04 (open)
    When I cancel the purchase "Course"
    Then the purchase "Course" is "cancelled"
    And installment 3 of the purchase "Course" is cancelled and still recorded
    And there is the refund "Course" of R$ 800.00 on card "Purple" on 2026-03-15 linked to the purchase "Course", in the 2026-04 statement
    And the realized Outflows for 2026-01 are R$ 400.00
    And the realized Outflows for 2026-02 are R$ 400.00
    And the realized Outflows for 2026-03 are -R$ 800.00
    And the forecast Outflows for 2026-03 are -R$ 800.00

  @EST-5 @EST-4 @edge
  Scenario Outline: Cancelling settles the difference with refunds already linked and the purchase closes at R$ 0.00
    Given the purchase "Course" of R$ 1,200.00 on card "Purple" on 2026-01-10 in 3 installments
    And the refund "Course discount" of <prior refund> on card "Purple" on 2026-02-15 linked to the purchase "Course"
    When I cancel the purchase "Course"
    Then the settlement generated on 2026-03-15 in the 2026-04 statement of card "Purple" is <settlement>
    And the realized Outflows for 2026-01 are R$ 400.00
    And the realized Outflows for 2026-02 are <outflows Feb>
    And the realized Outflows for 2026-03 are <outflows Mar>
    And the net effect of the purchase "Course" on the indicators is R$ 0.00

    Examples:
      | prior refund | settlement                                               | outflows Feb | outflows Mar |
      | R$ 100.00    | the linked refund "Course" of R$ 700.00                  | R$ 300.00    | -R$ 700.00   |
      | R$ 800.00    | none                                                     | -R$ 400.00   | R$ 0.00      |
      | R$ 1,000.00  | the linked charge "Cancellation settlement" of R$ 200.00 | -R$ 600.00   | R$ 200.00    |

  @EST-5 @EST-3 @IND-3 @edge
  Scenario: The cancellation settlement of a daily spending purchase counts in Daily spending, in today's month
    Given the purchase "Monthly Groceries" of R$ 1,200.00 on card "Purple" on 2026-01-10 in 3 installments, as daily spending
    And the refund "Groceries discount" of R$ 1,000.00 on card "Purple" on 2026-02-15 linked to the purchase "Monthly Groceries"
    When I cancel the purchase "Monthly Groceries"
    Then the settlement generated on 2026-03-15 in the 2026-04 statement of card "Purple" is the linked charge "Cancellation settlement" of R$ 200.00
    And the realized Daily spending for 2026-01 is R$ 400.00
    And the realized Daily spending for 2026-02 is -R$ 600.00
    And the realized Daily spending for 2026-03 is R$ 200.00
    And the realized Outflows for 2026-03 are R$ 0.00
    And the net effect of the purchase "Monthly Groceries" on the indicators is R$ 0.00

  @EST-6 @IND-2
  Scenario: Closing the remaining installments does not generate a refund
    Given the purchase "Course" of R$ 1,200.00 on card "Purple" on 2026-01-10 in 3 installments
    When I close the remaining installments of the purchase "Course"
    Then installment 3 of the purchase "Course" is "cancelled"
    And there is no refund linked to the purchase "Course"
    And the realized Outflows for 2026-01 are R$ 400.00
    And the realized Outflows for 2026-02 are R$ 400.00
    And the forecast Outflows for 2026-03 are R$ 0.00
