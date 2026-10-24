Feature: What can be daily spending

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @LAN-6
  Scenario: An expense is created as not daily spending by default
    When I add the expense "Coffee" of R$ 8.50 to account "Nubank" on 2026-03-15
    Then the expense "Coffee" is not daily spending

  @LAN-6 @CON-6
  Scenario Outline: Daily spending flag eligibility
    When I fill in <entry> <source>
    Then the option "as daily spending" is <state>

    Examples:
      | entry             | source                                    | state       |
      | an expense        | in account "Nubank"                       | available   |
      | an expense        | in account "Wallet"                       | available   |
      | an expense        | on card "Purple"                          | available   |
      | an expense        | to account "Reserve"                      | unavailable |
      | an income         | in account "Nubank"                       | unavailable |
      | an account refund | in account "Nubank"                       | unavailable |
      | a refund          | on card "Purple"                          | unavailable |
      | a transfer        | from account "Nubank" to account "Wallet" | unavailable |

  @LAN-6 @error
  Scenario: Forcing the flag on a saving account expense is blocked
    When I add the expense "Fee" of R$ 10.00 to account "Reserve" on 2026-03-15 flagged as daily spending
    Then the operation is blocked with the message "Only an expense in a spending account or on a card can be daily spending"

  @LAN-6 @TAG-4
  Scenario: A tag that flags automatically turns on daily spending on an eligible expense
    Given the tag "groceries" that marks daily spending
    When I add the expense "Bread" of R$ 12.00 to account "Nubank" on 2026-03-15 with the tags "groceries"
    Then the expense "Bread" is daily spending

  @LAN-6 @TAG-4 @edge
  Scenario: A tag that flags automatically does not turn on daily spending on an ineligible expense
    Given the tag "groceries" that marks daily spending
    When I add the expense "Fee" of R$ 10.00 to account "Reserve" on 2026-03-15 with the tags "groceries"
    Then the expense "Fee" is not daily spending
    And the expense "Fee" has the tags "groceries"

  @LAN-6 @LAN-8 @edge
  Scenario Outline: An edit that makes the expense ineligible removes the daily spending flag
    Given the expense "Coffee" of R$ 8.50 in account "Nubank" on 2026-03-15, confirmed, as daily spending
    When I edit the expense "Coffee" <change>
    Then the entry "Coffee" is not daily spending
    And I see the warning "This entry is no longer daily spending"

    Examples:
      | change                         |
      | moving it to account "Reserve" |
      | switching the type to income   |
