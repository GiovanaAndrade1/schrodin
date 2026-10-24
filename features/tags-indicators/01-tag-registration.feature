Feature: Tag registration

  Background:
    Given today is 2026-03-15

  @TAG-1
  Scenario: Creating a tag with name and color, without an icon
    When I create the tag "groceries" with the color "green"
    Then the tag "groceries" exists with the color "green" and no icon

  @TAG-1
  Scenario: Creating a tag with an icon
    When I create the tag "transport" with the color "blue" and the icon "bus"
    Then the tag "transport" exists with the color "blue" and the icon "bus"

  @TAG-1 @edge
  Scenario: A tag created without choosing a color gets the default automatic color
    When I create the tag "leisure" without choosing a color
    Then the tag "leisure" exists with an automatic color

  @TAG-1 @GER-9 @edge
  Scenario Outline: Names accepted at the limit (visible characters, NFC)
    When I create the tag "<name>" with the color "green"
    Then the tag "<name>" exists

    Examples:
      | name                           | case                                      |
      | a                              | 1 character                               |
      | Streaming and app subscription | 30 characters                             |
      | Eating out and café pâtisserie | 30 visible characters (32 if it were NFD) |

  @TAG-1 @GER-9 @error @edge
  Scenario Outline: Rejected names
    When I create the tag "<name>" with the color "green"
    Then the operation is blocked with the message "<message>"
    And no tag is created

    Examples:
      | name                            | message                                   |
      | Streaming and app subscriptions | The tag name must have 1 to 30 characters |
      | Eating out and café pâtisseries | The tag name must have 1 to 30 characters |
      |                                 | Enter the tag name                        |

  @TAG-1 @GER-9 @error @edge
  Scenario: A name with only spaces is empty
    When I create the tag "     " with the color "green"
    Then the operation is blocked with the message "Enter the tag name"

  @TAG-1 @GER-9 @edge
  Scenario: Leading and trailing spaces are removed before counting and saving
    When I create the tag "  Streaming and app subscription  " with the color "green"
    Then the tag "Streaming and app subscription" exists
    And the saved name has no leading or trailing spaces

  @TAG-1 @GER-9 @edge
  Scenario: Repeated internal spaces are collapsed when saving and counting
    When I create the tag "Mercado    Livre" with the color "blue"
    Then the tag "Mercado Livre" exists
    And the saved name has 13 characters

  @TAG-2 @GER-9 @error
  Scenario Outline: A name that is equal after normalization is rejected
    Given the tag "Groceries"
    When I create the tag "<name>" with the color "blue"
    Then the operation is blocked with the message "The tag Groceries already exists"

    Examples:
      | name      |
      | Groceries |
      | groceries |
      | GROCERIES |
      | gróceries |
      | Groceriés |
      | GRÓCERIES |

  @TAG-2 @GER-9 @error @edge
  Scenario: Normalized comparison applies after trimming and collapsing spaces
    Given the tag "Mercado Livre"
    When I create the tag "  mercado   livre " with the color "blue"
    Then the operation is blocked with the message "The tag Mercado Livre already exists"

  @TAG-2
  Scenario Outline: Similar but different names are accepted
    Given the tag "Groceries"
    When I create the tag "<name>" with the color "blue"
    Then the tag "<name>" exists
    And the tag "Groceries" still exists

    Examples:
      | name          |
      | Grocery       |
      | Mercado Livre |
      | Grocerie      |

  @TAG-2
  Scenario: A tag is saved as typed and found by its normalized name
    When I create the tag "Héalth" with the color "red"
    Then the tag "Héalth" exists with the name exactly "Héalth"
    When I type "HEALTH" in the entry's tag picker
    Then the picker offers the existing tag "Héalth"

  @TAG-2 @edge
  Scenario: Renaming a tag to a variation of itself is allowed
    Given the tag "groceries"
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the expense "Market" of R$ 85.40 in account "Nubank" on 2026-03-14, confirmed, with the tag "groceries"
    When I rename the tag "groceries" to "Groceries"
    Then the tag "Groceries" exists
    And the expense "Market" has the tags "Groceries"

  @TAG-2 @error
  Scenario: Renaming to the normalized name of another tag is blocked
    Given the tag "Groceries"
    And the tag "store"
    When I rename the tag "store" to "GROCERIES"
    Then the operation is blocked with the message "The tag Groceries already exists"
    And the tag "store" still exists
