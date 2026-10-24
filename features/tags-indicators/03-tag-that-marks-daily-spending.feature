Feature: Tag that automatically marks "daily spending"

  Background:
    Given today is 2026-03-15
    And the projection horizon is 12 months
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the tag "groceries" that marks daily spending
    And the tag "pharmacy"

  @TAG-4 @LAN-6
  Scenario: An expense in a spending account with the tag becomes daily spending
    When I add the expense "Market" of R$ 85.40 to account "Wallet" on 2026-03-15 with the tag "groceries"
    Then the expense "Market" is daily spending

  @TAG-4 @LAN-6
  Scenario: A card purchase with the tag becomes daily spending
    When I add the purchase "Supermarket" of R$ 412.30 to card "Purple" on 2026-03-14 with the tag "groceries"
    Then the purchase "Supermarket" is daily spending

  @TAG-4 @LAN-6 @edge
  Scenario Outline: An ineligible entry gets the tag but does not become daily spending
    When I add <entry> with the tag "groceries"
    Then the entry "<title>" has the tags "groceries"
    And the entry "<title>" is not daily spending

    Examples:
      | entry                                                                                               | title           |
      | the income "Sale" of R$ 50.00 to account "Nubank" on 2026-03-15                                     | Sale            |
      | the expense "Farm Groceries" of R$ 200.00 to account "Reserve" on 2026-03-15                        | Farm Groceries  |
      | the transfer "Cash Withdrawal" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15 | Cash Withdrawal |
      | the refund "Return" of R$ 30.00 to card "Purple" on 2026-03-15                                      | Return          |

  @TAG-4
  Scenario: A tag without the option does not mark
    When I add the expense "Medicine" of R$ 45.00 to account "Nubank" on 2026-03-15 with the tag "pharmacy"
    Then the expense "Medicine" is not daily spending

  @TAG-4
  Scenario: One marking tag is enough
    When I add the expense "Mixed Purchase" of R$ 70.00 to account "Nubank" on 2026-03-15 with the tags "pharmacy, groceries"
    Then the expense "Mixed Purchase" is daily spending

  @TAG-4 @LAN-6
  Scenario: The user can uncheck the daily spending the tag marked
    When I add the expense "Big Market" of R$ 380.00 to account "Nubank" on 2026-03-15 with the tag "groceries" and uncheck "as daily spending"
    Then the expense "Big Market" is not daily spending
    And the expense "Big Market" has the tags "groceries"

  @TAG-4
  Scenario: Turning on the option is not retroactive
    Given the expense "Medicine" of R$ 45.00 in account "Nubank" on 2026-03-10, confirmed, with the tag "pharmacy"
    When I turn on the option "daily spending flag" of the tag "pharmacy"
    Then the expense "Medicine" is not daily spending
    When I add the expense "Vitamins" of R$ 60.00 to account "Nubank" on 2026-03-15 with the tag "pharmacy"
    Then the expense "Vitamins" is daily spending

  @TAG-4
  Scenario: Turning off the option is not retroactive
    Given the expense "Market" of R$ 85.40 in account "Wallet" on 2026-03-10, confirmed, with the tag "groceries"
    And the expense "Market" is daily spending
    When I turn off the option "daily spending flag" of the tag "groceries"
    Then the expense "Market" is daily spending
    When I add the expense "Butcher" of R$ 95.00 to account "Wallet" on 2026-03-15 with the tag "groceries"
    Then the expense "Butcher" is not daily spending

  @TAG-4
  Scenario: Removing the tag from the entry does not unflag daily spending
    Given the expense "Market" of R$ 85.40 in account "Wallet" on 2026-03-10, confirmed, with the tag "groceries"
    When I remove the tag "groceries" from the expense "Market"
    Then the expense "Market" has no tags
    And the expense "Market" is daily spending

  @TAG-4
  Scenario: Adding the tag by editing an existing expense marks it as daily spending
    Given the expense "Bread" of R$ 12.00 in account "Nubank" on 2026-03-14, confirmed
    And the expense "Bread" is not daily spending
    When I add the tag "groceries" to the expense "Bread"
    Then the expense "Bread" is daily spending

  @TAG-4 @REC-4 @GER-12
  Scenario: Occurrences generated after turning on the option are flagged; already generated ones are not
    Given the recurring expense "Ongoing Medicine" of R$ 45.00 in account "Nubank", monthly, starting 2026-03-20, with no end, with the tag "pharmacy"
    And the series "Ongoing Medicine" has 12 generated occurrences, from 2026-03-20 to 2027-02-20, none of them daily spending
    When I turn on the option "daily spending flag" of the tag "pharmacy"
    And I change the projection horizon to 13 months
    Then the 2027-03-20 occurrence of series "Ongoing Medicine" is daily spending
    And the 2026-03-20 occurrence of series "Ongoing Medicine" is not daily spending

  @TAG-4 @LAN-8 @LAN-6 @edge
  Scenario: Moving a flagged expense to a saving account removes the flag; moving it back does not flag it again
    Given the expense "Market" of R$ 85.40 in account "Wallet" on 2026-03-14, confirmed, with the tag "groceries"
    When I edit the expense "Market" to account "Reserve"
    Then I see the warning "An expense in a saving account can't be daily spending; the flag was removed"
    And the expense "Market" is not daily spending
    And the expense "Market" has the tags "groceries"
    When I edit the expense "Market" to account "Wallet"
    Then the expense "Market" is not daily spending
