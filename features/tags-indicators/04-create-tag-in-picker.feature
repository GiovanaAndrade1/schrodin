Feature: Tag creation directly in the entry's picker

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the tag "Groceries"
    And I am adding the expense "Market" of R$ 85.40 to account "Nubank" on 2026-03-15

  @TAG-5
  Scenario: A new name offers creation, with an automatic color and no daily spending flag
    When I type "street market" in the entry's tag picker
    Then the picker offers the option Create "street market"
    When I choose the option Create "street market" and save the entry
    Then the tag "street market" exists with an automatic color
    And the tag "street market" does not mark daily spending
    And the expense "Market" has the tags "street market"
    And the expense "Market" is not daily spending

  @TAG-5 @TAG-2
  Scenario Outline: An existing normalized name offers the existing tag, not creation
    When I type "<typed>" in the entry's tag picker
    Then the picker offers the existing tag "Groceries"
    And the picker does not offer the option to create

    Examples:
      | typed     |
      | Groceries |
      | GROCERIES |
      | gróceries |
      | groceriés |

  @TAG-5 @GER-9 @edge
  Scenario: Trimming and collapsing spaces in inline creation
    When I type "  local   produce   shop  " in the entry's tag picker
    Then the picker offers the option Create "local produce shop"

  @TAG-5 @TAG-1 @error @edge
  Scenario: A name with more than 30 characters cannot be created inline
    When I type "Streaming and app subscriptions" in the entry's tag picker
    Then the picker does not offer the option to create
    And I see the warning "The tag name must have 1 to 30 characters"

  @TAG-5 @GER-9 @edge
  Scenario: Only spaces does not offer creation
    When I type "   " in the entry's tag picker
    Then the picker does not offer the option to create
