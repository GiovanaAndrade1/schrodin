Feature: Amount field with expression

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01

  @LAN-4 @GER-10 @GER-1
  Scenario Outline: A valid expression becomes an amount in cents
    When I type "<expression>" in the amount
    And I save the expense "Test" in account "Nubank" on 2026-03-15
    Then the amount of the expense "Test" is <amount>

    Examples:
      | expression        | amount           | note                                           |
      | 35,90             | R$ 35.90         | decimal comma                                  |
      | 35,9              | R$ 35.90         | one decimal place                              |
      | 120+35,90         | R$ 155.90        | sum                                            |
      | 100−30            | R$ 70.00         | unicode minus                                  |
      | 100-30            | R$ 70.00         | ASCII hyphen                                   |
      | 12×3              | R$ 36.00         | unicode times                                  |
      | 12*3              | R$ 36.00         | asterisk                                       |
      | 12x3              | R$ 36.00         | letter x                                       |
      | 100÷4             | R$ 25.00         | exact division                                 |
      | 100/4             | R$ 25.00         | slash                                          |
      | 10+5×2            | R$ 20.00         | precedence: × before +                         |
      | (10+5)×2          | R$ 30.00         | parentheses                                    |
      | ((2+3)×(4−1))÷2   | R$ 7.50          | nested parentheses: 15÷2                       |
      | 10−20+30          | R$ 20.00         | negative intermediate is ok                    |
      | -50+100           | R$ 50.00         | unary minus                                    |
      | -(10−30)          | R$ 20.00         | unary minus before parentheses                 |
      | 10÷3              | R$ 3.33          | 3.333… rounds down                             |
      | 20÷3              | R$ 6.67          | 6.666… rounds up                               |
      | 1÷8               | R$ 0.13          | 0.125 → half away from zero                    |
      | 0,01÷2            | R$ 0.01          | 0.005 → half away from zero                    |
      | 1,005             | R$ 1.01          | exact (float would give 1.00)                  |
      | 2,675             | R$ 2.68          | exact (float would give 2.67)                  |
      | 10÷3×3            | R$ 10.00         | no intermediate rounding                       |
      | 100÷3+100÷3+100÷3 | R$ 100.00        | no intermediate rounding                       |
      | 1.234,56          | R$ 1,234.56      | thousands separator                            |
      | 1.234             | R$ 1,234.00      | a dot in a group of 3 is a thousands separator |
      | 1234,56           | R$ 1,234.56      | no separator                                   |
      | 1.000.000         | R$ 1,000,000.00  | two separators                                 |
      | 120 + 35,90       | R$ 155.90        | spaces ignored                                 |
      | R$ 120,00         | R$ 120.00        | "R$" ignored                                   |
      | R$1.234,56        | R$ 1,234.56      | "R$" attached                                  |
      | ,50               | R$ 0.50          | comma with no digit on the left                |
      | 10,               | R$ 10.00         | comma with no digit on the right               |
      | 0,01              | R$ 0.01          | minimum                                        |
      | 99999999,99       | R$ 99,999,999.99 | maximum (GER-8)                                |
      | 99999999,99×2÷2   | R$ 99,999,999.99 | intermediate above the maximum is ok           |

  @LAN-4 @LAN-1 @GER-8 @error
  Scenario Outline: An invalid or out-of-range expression is rejected
    When I type "<expression>" in the amount
    And I save the expense "Test" in account "Nubank" on 2026-03-15
    Then the operation is blocked with the message "<message>"
    And the actual balance of account "Nubank" is R$ 1,000.00

    Examples:
      | expression       | message                                |
      |                  | Enter an amount                        |
      | 0                | The amount must be greater than zero   |
      | 0,00             | The amount must be greater than zero   |
      | 100−100          | The amount must be greater than zero   |
      | 50−80            | The amount must be greater than zero   |
      | -50              | The amount must be greater than zero   |
      | -10÷4            | The amount must be greater than zero   |
      | 1÷3×0            | The amount must be greater than zero   |
      | 0,004            | The amount must be greater than zero   |
      | 0,01÷3           | The amount must be greater than zero   |
      | 10÷0             | Division by zero                       |
      | 10÷(5−5)         | Division by zero                       |
      | 100000000        | The maximum amount is R$ 99,999,999.99 |
      | 99999999,99+0,01 | The maximum amount is R$ 99,999,999.99 |
      | 99999999,995     | The maximum amount is R$ 99,999,999.99 |
      | abc              | Invalid expression                     |
      | 10++5            | Invalid expression                     |
      | ÷5               | Invalid expression                     |
      | 5÷               | Invalid expression                     |
      | (10+5            | Invalid expression                     |
      | 10+5)            | Invalid expression                     |
      | 2(3+4)           | Invalid expression                     |
      | 1e3              | Invalid expression                     |
      | 1.5              | Invalid expression                     |
      | 1.23             | Invalid expression                     |
      | 12.34,56         | Invalid expression                     |
      | 1,234.56         | Invalid expression                     |
      | 1,2,3            | Invalid expression                     |

  @LAN-4
  Scenario: Only the result of the expression is saved
    Given I added the expense "Groceries" to account "Nubank" on 2026-03-15 typing "120+35,90" in the amount
    When I open the editing of the expense "Groceries"
    Then the amount field shows "155,90"

  @LAN-4 @LAN-8 @error
  Scenario: Editing with an invalid expression does not change the entry
    Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed
    When I edit the expense "Groceries" typing "50−80" in the amount
    Then the operation is blocked with the message "The amount must be greater than zero"
    And the amount of the expense "Groceries" is R$ 120.00
    And the actual balance of account "Nubank" is R$ 880.00
