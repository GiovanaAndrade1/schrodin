Feature: Entry title and note

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01

  @LAN-1 @GER-9 @error
  Scenario Outline: An empty or whitespace-only title is blocked
    When I add an expense of R$ 10.00 to account "Nubank" on 2026-03-15 with a title <title>
    Then the operation is blocked with the message "Enter a title"

    Examples:
      | title                 |
      | empty                 |
      | of 3 spaces           |
      | of 1 tab and 2 spaces |

  @LAN-1 @GER-9
  Scenario: Leading and trailing spaces are removed and repeated inner spaces collapse
    When I add the expense "   Morning   coffee  " of R$ 10.00 to account "Nubank" on 2026-03-15
    Then there is the expense "Morning coffee"

  @LAN-1 @edge
  Scenario Outline: 80-character limit
    When I add an expense of R$ 10.00 to account "Nubank" on 2026-03-15 with a title of <n> characters
    Then the result is "<result>"

    Examples:
      | n  | result                                            |
      | 1  | accepted                                          |
      | 80 | accepted                                          |
      | 81 | blocked: The title can have at most 80 characters |

  @LAN-1 @GER-9 @edge
  Scenario: The 80 limit is counted after the trim
    When I add an expense of R$ 10.00 to account "Nubank" on 2026-03-15 with a title of 80 characters and 3 spaces at each end
    Then the expense is saved with a title of 80 characters

  @LAN-1 @GER-9 @edge
  Scenario: The 80 limit is counted after collapsing inner spaces
    When I add an expense of R$ 10.00 to account "Nubank" on 2026-03-15 with a title of 81 characters where one of them is a second consecutive space
    Then the expense is saved with a title of 80 characters

  @LAN-1 @GER-9 @edge
  Scenario: A composed emoji counts as one character
    When I add an expense of R$ 10.00 to account "Nubank" on 2026-03-15 with a title of 79 letters followed by "👨‍👩‍👧"
    Then the expense is saved with a title of 80 characters

  @GER-13 @edge
  Scenario Outline: A note goes from 0 to 1,000 characters
    When I add the expense "Coffee" of R$ 10.00 to account "Nubank" on 2026-03-15 with a note of <n> characters
    Then the result is "<result>"

    Examples:
      | n    | result                                              |
      | 0    | accepted                                            |
      | 1000 | accepted                                            |
      | 1001 | blocked: The note can have at most 1,000 characters |

  @GER-13 @GER-9
  Scenario: A whitespace-only note is saved empty
    When I add the expense "Coffee" of R$ 10.00 to account "Nubank" on 2026-03-15 with note "    "
    Then the expense "Coffee" has no note
