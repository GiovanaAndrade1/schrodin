Feature: Account refund of a paid expense

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the expense "Headphones" of R$ 200.00 in account "Nubank" on 2026-03-05, confirmed

  @EST-7 @CON-4 @IND-1 @IND-2
  Scenario: An account refund enters the balance and reduces Outflows, without counting as an Inflow
    When I add the account refund "Headphones" of R$ 200.00 to account "Nubank" on 2026-03-12 linked to the expense "Headphones"
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the realized Inflows for 2026-03 are R$ 0.00
    And the realized Outflows for 2026-03 are R$ 0.00

  @EST-7 @EST-4 @edge @error
  Scenario Outline: The account refund cap is the expense amount minus other account refunds
    Given the expense "Headphones" already has R$ <previous> in linked account refunds
    When I add the account refund "Headphones" of R$ <new> to account "Nubank" on 2026-03-12 linked to the expense "Headphones"
    Then the result is "<result>"

    Examples:
      | previous | new    | result                                             |
      | 0.00     | 200.00 | accepted                                           |
      | 0.00     | 200.01 | blocked: The account refund can't exceed R$ 200.00 |
      | 150.00   | 50.00  | accepted                                           |
      | 150.00   | 50.01  | blocked: The account refund can't exceed R$ 50.00  |

  @EST-7 @error
  Scenario: An account refund must be in the same account as the expense
    When I add the account refund "Headphones" of R$ 50.00 to account "Wallet" on 2026-03-12 linked to the expense "Headphones"
    Then the operation is blocked with the message "The linked expense must be in the same account"

  @EST-7 @error
  Scenario Outline: An account refund only links to a confirmed expense dated up to its own date
    Given the expense "Course" of R$ 300.00 in account "Nubank" on 2026-03-20, planned
    And the expense "Book" of R$ 80.00 in account "Nubank" on 2026-03-14, confirmed
    When I add the account refund "Test" of R$ 10.00 to account "Nubank" on <date> linked to the expense "<expense>"
    Then the operation is blocked with the message "<message>"

    Examples:
      | date       | expense | message                                              |
      | 2026-03-15 | Course  | You can only link to a confirmed expense             |
      | 2026-03-13 | Book    | The linked expense can't be after the account refund |

  @EST-7 @EST-1
  Scenario: An account refund is created with the expense's tags, which can be changed
    Given the expense "Headphones" has the tags "electronics"
    When I open the account refund form linked to the expense "Headphones"
    Then the form tags are "electronics"

  @EST-7 @EST-3 @IND-3
  Scenario: An account refund of a daily spending expense reduces Daily spending
    Given the expense "Lunch" of R$ 45.00 in account "Nubank" on 2026-03-10, confirmed, as daily spending
    When I add the account refund "Lunch" of R$ 15.00 to account "Nubank" on 2026-03-11 linked to the expense "Lunch"
    Then the realized Daily spending for 2026-03 is R$ 30.00
    And the realized Outflows for 2026-03 are R$ 200.00

  @EST-7 @EST-4 @error
  Scenario: An expense cannot become smaller than its account refunds
    Given the account refund "Headphones" of R$ 120.00 in account "Nubank" on 2026-03-12 linked to the expense "Headphones"
    When I edit the expense "Headphones" to R$ 100.00
    Then the operation is blocked with the message "The expense has R$ 120.00 in linked account refunds"

  @EST-7 @LAN-3
  Scenario: A regular unlinked income still counts as an Inflow
    When I add the income "Pix from Ana" of R$ 200.00 to account "Nubank" on 2026-03-12
    Then the realized Inflows for 2026-03 are R$ 200.00
    And the realized Outflows for 2026-03 are R$ 200.00
