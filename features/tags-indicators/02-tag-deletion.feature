Feature: Tag deletion

  Background:
    Given today is 2026-03-15
    And the projection horizon is 12 months
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the tag "leisure"
    And the tag "transport"
    And the expense "Movies" of R$ 60.00 in account "Nubank" on 2026-03-07, confirmed, with the tags "leisure, transport"
    And the purchase "Concert" of R$ 250.00 on card "Purple" on 2026-03-12 with the tag "leisure"
    And the expense "Park" of R$ 40.00 in account "Wallet" on 2026-03-20, planned, with the tag "leisure"

  @TAG-3
  Scenario: Deleting a used tag shows the count and removes it from the entries without deleting them
    When I delete the tag "leisure"
    Then I see the confirmation prompt "The tag leisure is on 3 entries. They won't be deleted, they just lose the tag."
    When I confirm the deletion
    Then the tag "leisure" does not exist
    And the expense "Movies" has the tags "transport"
    And the purchase "Concert" has no tags
    And the expense "Park" has no tags
    And the expense "Movies" still has R$ 60.00 on 2026-03-07
    And the purchase "Concert" still has R$ 250.00 in the 2026-04 statement of card "Purple"

  @TAG-3
  Scenario: Cancelling the deletion changes nothing
    When I delete the tag "leisure"
    And I cancel the deletion
    Then the tag "leisure" exists
    And the purchase "Concert" has the tags "leisure"

  @TAG-3 @TAG-9
  Scenario: An entry that loses its only tag moves to "Untagged" in the report
    When I delete the tag "leisure" and confirm
    Then the realized tag report for 2026-03 shows:
      | tag       | expenses  | income  |
      | transport | R$ 60.00  | R$ 0.00 |
      | Untagged  | R$ 250.00 | R$ 0.00 |

  @TAG-3 @edge
  Scenario: Deleting an unused tag
    Given the tag "travel"
    When I delete the tag "travel"
    Then I see the confirmation prompt "The tag travel isn't on any entry."
    When I confirm the deletion
    Then the tag "travel" does not exist

  @TAG-3 @TAG-4
  Scenario: Deleting a tag that marks daily spending does not unflag the entries
    Given the tag "groceries" that marks daily spending
    And the expense "Market" of R$ 85.40 in account "Wallet" on 2026-03-14, confirmed, with the tag "groceries"
    And the expense "Market" is daily spending
    When I delete the tag "groceries" and confirm
    Then the expense "Market" has no tags
    And the expense "Market" is daily spending

  @TAG-3 @PAR-4 @edge
  Scenario: An installment purchase counts as one entry in the confirmation
    Given the tag "household"
    And the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments with the tag "household"
    And the expense "Paint" of R$ 150.00 in account "Nubank" on 2026-03-11, confirmed, with the tag "household"
    When I delete the tag "household"
    Then I see the confirmation prompt "The tag household is on 2 entries. They won't be deleted, they just lose the tag."
    When I confirm the deletion
    Then none of the 10 installments of the purchase "TV" has tags

  @TAG-3 @GER-12 @edge
  Scenario: A series counts the generated occurrences and the tag leaves the series template
    Given the tag "health"
    And the recurring expense "Gym" of R$ 120.00 in account "Nubank", monthly, starting 2026-01-20, with no end, with the tag "health"
    Then the series "Gym" has 14 generated occurrences, from 2026-01-20 to 2027-02-20
    When I delete the tag "health"
    Then I see the confirmation prompt "The tag health is on 14 entries. They won't be deleted, they just lose the tag."
    When I confirm the deletion
    And I change the projection horizon to 13 months
    Then the 2027-03-20 occurrence of series "Gym" is generated without tags
