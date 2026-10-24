Feature: Actual balance and opening date limit

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01

  @CON-4 @INV-1
  Scenario: The actual balance sums only what is confirmed
    Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-03-05, confirmed
    And the expense "Rent" of R$ 1,500.00 in account "Nubank" on 2026-03-10, confirmed
    And the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-06, confirmed
    And the transfer "Withdrawal" of R$ 200.00 from account "Reserve" to account "Nubank" on 2026-03-12, confirmed
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-20, planned
    And the income "Bonus" of R$ 300.00 in account "Nubank" on 2026-03-25, planned
    And the outflow adjustment of R$ 15.00 in account "Nubank" on 2026-03-13
    Then the actual balance of account "Nubank" is R$ 4,185.00
    And the actual balance of account "Reserve" is R$ 300.00

  @CON-4 @STA-3
  Scenario: An overdue entry does not count in the actual balance
    Given the expense "Internet" of R$ 100.00 in account "Nubank" on 2026-03-10, planned
    Then the expense "Internet" is "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @CON-4
  Scenario: Confirming a planned entry changes the actual balance
    Given the expense "Internet" of R$ 100.00 in account "Nubank" on 2026-03-10, planned
    When I confirm the expense "Internet" with amount R$ 99.90 on 2026-03-10
    Then the actual balance of account "Nubank" is R$ 900.10

  @CON-4 @FAT-7
  Scenario: A card purchase does not touch the balance; the statement payment does
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-02-10
    Then the actual balance of account "Nubank" is R$ 1,000.00
    When I pay R$ 300.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08
    Then the actual balance of account "Nubank" is R$ 700.00

  @CON-4 @CON-2
  Scenario: A negative opening balance goes into the account as overdraft
    Given the account "Itaú" of kind "checking" with opening balance -R$ 500.00 on 2026-03-01
    And the income "Pix" of R$ 200.00 in account "Itaú" on 2026-03-02, confirmed
    Then the actual balance of account "Itaú" is -R$ 300.00

  @CON-4 @GER-8 @GER-1 @edge
  Scenario: The actual balance can exceed the maximum of a single amount
    Given the account "Itaú" of kind "checking" with opening balance R$ 99,999,999.99 on 2026-03-01
    And the income "Sale" of R$ 99,999,999.99 in account "Itaú" on 2026-03-02, confirmed
    Then the actual balance of account "Itaú" is R$ 199,999,999.98

  @CON-3 @CON-4 @edge
  Scenario: An entry on the same day as the opening balance is added to it
    Given the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    When I add the expense "Bakery" of R$ 20.00 to account "Itaú" on 2026-03-01
    Then the actual balance of account "Itaú" is R$ 980.00

  @CON-3 @TRF-6 @FAT-7 @INV-7 @error @edge
  Scenario Outline: No entry before the opening date
    Given the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Itaú" and start date 2026-01-01
    And the purchase "Headphones" of R$ 30.00 on card "Purple" on 2026-02-20
    When I <action> on 2026-02-28
    Then the operation is blocked with the message "The date can't be before the opening balance of account Itaú (2026-03-01)"

    Examples:
      | action                                                                        |
      | add the income "Pix" of R$ 100.00 to account "Itaú"                           |
      | add the expense "Bakery" of R$ 20.00 to account "Itaú"                        |
      | add the transfer "Save" of R$ 50.00 from account "Itaú" to account "Nubank"   |
      | add the transfer "Top-up" of R$ 50.00 from account "Nubank" to account "Itaú" |
      | pay R$ 30.00 of the 2026-03 statement of card "Purple" from account "Itaú"    |

  @CON-3 @TRF-6 @FAT-7 @edge
  Scenario Outline: The same entries on the opening date are accepted
    Given the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Itaú" and start date 2026-01-01
    And the purchase "Headphones" of R$ 30.00 on card "Purple" on 2026-02-20
    When I <action> on 2026-03-01
    Then the entry is saved
    And the actual balance of account "Itaú" is <balance>

    Examples:
      | action                                                                        | balance     |
      | add the income "Pix" of R$ 100.00 to account "Itaú"                           | R$ 1,100.00 |
      | add the expense "Bakery" of R$ 20.00 to account "Itaú"                        | R$ 980.00   |
      | add the transfer "Save" of R$ 50.00 from account "Itaú" to account "Nubank"   | R$ 950.00   |
      | add the transfer "Top-up" of R$ 50.00 from account "Nubank" to account "Itaú" | R$ 1,050.00 |
      | pay R$ 30.00 of the 2026-03 statement of card "Purple" from account "Itaú"    | R$ 970.00   |

  @CON-3 @LAN-8 @error
  Scenario: Moving an entry to an account whose opening date is later is blocked
    Given the account "Itaú" of kind "checking" with opening balance R$ 1,000.00 on 2026-03-01
    And the expense "Bakery" of R$ 20.00 in account "Nubank" on 2026-02-20, confirmed
    When I edit the expense "Bakery" switching the account to "Itaú"
    Then the operation is blocked with the message "The date can't be before the opening balance of account Itaú (2026-03-01)"
    And the expense "Bakery" is still in account "Nubank"
