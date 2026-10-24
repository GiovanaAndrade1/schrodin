Feature: Account installments (payment book, boleto)
  Background:
    Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the projection horizon is 12 months

  @PAR-1 @REC-3 @edge
  Scenario Outline: Installment dates follow the anchor day of the 1st
    Given today is <today>
    When I add the expense "Payment Book" of R$ <total> to account "Nubank" in <N> installments with installment 1 on <first>
    Then the installment dates of the expense "Payment Book" are "<dates>"

    Examples:
      | today      | total  | first      | N | dates                                          |
      | 2026-01-15 | 400.00 | 2026-01-31 | 4 | 2026-01-31, 2026-02-28, 2026-03-31, 2026-04-30 |
      | 2026-03-15 | 300.00 | 2026-12-31 | 3 | 2026-12-31, 2027-01-31, 2027-02-28             |
      | 2027-12-01 | 300.00 | 2028-01-30 | 3 | 2028-01-30, 2028-02-29, 2028-03-30             |
      | 2026-03-15 | 200.00 | 2026-03-29 | 2 | 2026-03-29, 2026-04-29                         |

  @PAR-1 @PAR-2 @PAR-8
  Scenario: A payment book in an account generates independent planned entries
    Given today is 2026-03-15
    When I add the expense "Payment Book" of R$ 600.00 to account "Nubank" in 6 installments with installment 1 on 2026-03-31
    Then the expense "Payment Book" has 6 installments of R$ 100.00, from 2026-03-31 to 2026-08-31
    And the 6 installments of the expense "Payment Book" are "planned"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @PAR-8 @STA-3
  Scenario: One installment can be confirmed while another becomes overdue
    Given today is 2026-03-15
    And the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-04-10
    When the day turns to 2026-05-12
    And I confirm installment 1/3 of the expense "Course"
    Then installment 1/3 of the expense "Course" is "confirmed"
    And installment 2/3 of the expense "Course" is "overdue"
    And installment 3/3 of the expense "Course" is "planned"
    And the actual balance of account "Nubank" is R$ 700.00

  @PAR-8 @STA-5 @INV-4
  Scenario: Confirming an installment with a different amount changes the total of the account purchase
    Given today is 2026-03-15
    And the expense "Course" of R$ 900.00 in account "Nubank" in 3 installments with installment 1 on 2026-04-10
    When the day turns to 2026-05-12
    And I confirm installment 2/3 of the expense "Course" with amount R$ 305.00 on 2026-05-12
    Then installment 2/3 of the expense "Course" is R$ 305.00
    And installments 1/3 and 3/3 of the expense "Course" are still R$ 300.00
    And the total amount of the expense "Course" is R$ 905.00

  @PAR-1 @STA-2 @edge
  Scenario: Payment book with the 1st installment in the past
    Given today is 2026-03-15
    When I add the expense "Payment Book" of R$ 300.00 to account "Nubank" in 3 installments with installment 1 on 2026-02-15
    Then the installments of the expense "Payment Book" are:
      | k | date       | status    |
      | 1 | 2026-02-15 | confirmed |
      | 2 | 2026-03-15 | confirmed |
      | 3 | 2026-04-15 | planned   |
    And the actual balance of account "Nubank" is R$ 800.00

  @PAR-1 @LAN-7 @GER-11 @edge
  Scenario: Account installments beyond the horizon are all created
    Given today is 2026-03-15
    When I add the expense "Financing" of R$ 2,400.00 to account "Nubank" in 24 installments with installment 1 on 2026-04-10
    Then the expense "Financing" has 24 installments of R$ 100.00, from 2026-04-10 to 2028-03-10

  @PAR-1 @CON-3 @error
  Scenario: A 1st installment before the opening balance is rejected
    Given today is 2026-03-15
    When I add the expense "Payment Book" of R$ 300.00 to account "Nubank" in 3 installments with installment 1 on 2025-12-15
    Then the operation is blocked with the message "The date can't be before the opening balance of account Nubank (2026-01-01)"
