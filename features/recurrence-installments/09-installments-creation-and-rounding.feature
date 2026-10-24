Feature: Installment purchase creation
  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months

  @PAR-1 @edge
  Scenario Outline: Number of installments from 2 to 72
    When I add the purchase "Test" of R$ 720.00 to card "Purple" on 2026-03-15 in <N> installments
    Then <result>

    Examples:
      | N  | result                                                                                                    |
      | 2  | the purchase "Test" has 2 installments                                                                    |
      | 72 | the purchase "Test" has 72 installments                                                                   |
      | 1  | the operation is blocked with the message "Split into 2 to 72 installments or add it as a single payment" |
      | 73 | the operation is blocked with the message "Split into 2 to 72 installments or add it as a single payment" |
      | 0  | the operation is blocked with the message "Split into 2 to 72 installments or add it as a single payment" |

  @PAR-1 @error
  Scenario Outline: Only an expense can be split into installments
    When I try to add <kind> of R$ 600.00 in 3 installments
    Then the operation is blocked with the message "Only an expense can be split into installments"

    Examples:
      | kind                                                           |
      | the income "Freelance" to account "Nubank"                     |
      | the transfer "Save" from account "Nubank" to account "Reserve" |
      | the refund "Sneakers" to card "Purple"                         |

  @PAR-2 @GER-10 @INV-4 @edge
  Scenario Outline: From the total, the whole division remainder goes to the first installment
    When I add the purchase "Test" of <total> to card "Purple" on 2026-03-15 in <N> installments
    Then installment 1 of the purchase "Test" is <first>
    And installments 2 to <N> of the purchase "Test" are <others> each
    And the sum of the installments of the purchase "Test" is <total>

    Examples:
      | total            | N  | first           | others          |
      | R$ 1,000.00      | 3  | R$ 333.34       | R$ 333.33       |
      | R$ 100.00        | 7  | R$ 14.32        | R$ 14.28        |
      | R$ 10.00         | 3  | R$ 3.34         | R$ 3.33         |
      | R$ 1,000.00      | 6  | R$ 166.70       | R$ 166.66       |
      | R$ 3,000.00      | 10 | R$ 300.00       | R$ 300.00       |
      | R$ 0.05          | 2  | R$ 0.03         | R$ 0.02         |
      | R$ 0.02          | 2  | R$ 0.01         | R$ 0.01         |
      | R$ 0.72          | 72 | R$ 0.01         | R$ 0.01         |
      | R$ 1.00          | 72 | R$ 0.29         | R$ 0.01         |
      | R$ 99,999,999.99 | 72 | R$ 1,388,889.51 | R$ 1,388,888.88 |

  @PAR-2 @LAN-1 @INV-4 @error @edge
  Scenario Outline: A total that does not give at least R$ 0.01 per installment is rejected
    When I add the purchase "Test" of <total> to card "Purple" on 2026-03-15 in <N> installments
    Then the operation is blocked with the message "Insufficient amount: the minimum for <N> installments is <minimum>"

    Examples:
      | total   | N  | minimum |
      | R$ 0.01 | 2  | R$ 0.02 |
      | R$ 0.71 | 72 | R$ 0.72 |

  @PAR-2 @INV-4
  Scenario: From the installment amount, the total is installment × N
    When I add the purchase "Sofa" to card "Purple" on 2026-03-15 in 3 installments of R$ 333.33
    Then the 3 installments of the purchase "Sofa" are R$ 333.33
    And the total amount of the purchase "Sofa" is R$ 999.99

  @PAR-2 @GER-8 @edge
  Scenario Outline: The installment purchase total respects the maximum amount
    When I add the purchase "Test" to card "Purple" on 2026-03-15 in 72 installments of <installment>
    Then <result>

    Examples:
      | installment     | result                                                                                                            |
      | R$ 1,388,888.88 | the total amount of the purchase "Test" is R$ 99,999,999.36                                                       |
      | R$ 1,388,888.89 | the operation is blocked with the message "The total (R$ 100,000,000.08) exceeds the maximum of R$ 99,999,999.99" |

  @PAR-3
  Scenario: Each installment shows (k/N) in the title
    When I add the purchase "TV" of R$ 3,000.00 to card "Purple" on 2026-03-10 in 10 installments
    Then installment 3 of the purchase "TV" appears as "TV (3/10)"
    And installment 10 of the purchase "TV" appears as "TV (10/10)"
