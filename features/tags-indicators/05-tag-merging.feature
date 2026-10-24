Feature: Tag merging

  Background:
    Given today is 2026-03-15
    And the projection horizon is 12 months
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01

  @TAG-6 @TAG-9
  Scenario: Merging moves the entries, does not duplicate and deletes the source
    Given the tag "store"
    And the tag "groceries"
    And the expense "Atacadão" of R$ 300.00 in account "Nubank" on 2026-02-10, confirmed, with the tag "store"
    And the expense "Market" of R$ 50.00 in account "Wallet" on 2026-02-12, confirmed, with the tag "groceries"
    And the expense "Monthly Shopping" of R$ 200.00 in account "Nubank" on 2026-02-14, confirmed, with the tags "store, groceries"
    When I merge the tag "store" into the tag "groceries"
    Then the tag "store" does not exist
    And the expense "Atacadão" has the tags "groceries"
    And the expense "Monthly Shopping" has the tag "groceries" only once
    And the realized tag report for 2026-02 shows:
      | tag       | expenses  | income  |
      | groceries | R$ 550.00 | R$ 0.00 |
    And the report does not show the multi-tag warning

  @TAG-6 @error
  Scenario: Merging a tag into itself is blocked
    Given the tag "groceries"
    When I merge the tag "groceries" into the tag "groceries"
    Then the operation is blocked with the message "Choose two different tags"
    And the tag "groceries" still exists

  @TAG-6 @GER-12
  Scenario: Merging also carries over the series template
    Given the tag "store"
    And the tag "groceries"
    And the recurring expense "Atacadão monthly" of R$ 300.00 in account "Nubank", monthly, starting 2026-03-25, with no end, with the tag "store"
    When I merge the tag "store" into the tag "groceries"
    Then all generated occurrences of series "Atacadão monthly" have the tags "groceries"
    When I change the projection horizon to 13 months
    Then the 2027-03-25 occurrence of series "Atacadão monthly" has the tags "groceries"

  @TAG-6 @TAG-4
  Scenario: Source marked daily spending, destination does not: entries keep the flag, new ones are not flagged
    Given the tag "market" that marks daily spending
    And the tag "groceries"
    And the expense "Market" of R$ 50.00 in account "Wallet" on 2026-03-12, confirmed, with the tag "market"
    And the expense "Market" is daily spending
    When I merge the tag "market" into the tag "groceries"
    Then the expense "Market" has the tags "groceries"
    And the expense "Market" is daily spending
    And the tag "groceries" does not mark daily spending
    When I add the expense "Produce" of R$ 30.00 to account "Wallet" on 2026-03-15 with the tag "groceries"
    Then the expense "Produce" is not daily spending

  @TAG-6 @TAG-4
  Scenario: Destination marks daily spending, source does not: the source's entries are not flagged
    Given the tag "store"
    And the tag "groceries" that marks daily spending
    And the expense "Atacadão" of R$ 300.00 in account "Nubank" on 2026-03-10, confirmed, with the tag "store"
    When I merge the tag "store" into the tag "groceries"
    Then the expense "Atacadão" has the tags "groceries"
    And the expense "Atacadão" is not daily spending
    When I add the expense "Market" of R$ 50.00 to account "Wallet" on 2026-03-15 with the tag "groceries"
    Then the expense "Market" is daily spending
