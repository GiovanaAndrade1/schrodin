Feature: Suggested tags on first use and picker order

  Background:
    Given today is 2026-03-15

  @TAG-7
  Scenario: First use suggests the initial set and creates only the chosen ones
    Given it is the first use of the app and there is no tag
    Then the app suggests the tags "groceries, transport, home, apps, leisure, health, eating out"
    And the app offers to turn on the daily spending flag only on "groceries" and "eating out"
    When I choose "groceries, transport, eating out", turn on the daily spending flag on "groceries" and confirm
    Then exactly the tags "eating out, groceries, transport" exist
    And the tag "groceries" marks daily spending
    And the tag "eating out" does not mark daily spending
    And the tag "transport" does not mark daily spending

  @TAG-7 @edge
  Scenario: Skipping the suggestion creates nothing and it does not come back on its own
    Given it is the first use of the app and there is no tag
    When I skip the tag suggestion
    Then there is no tag
    And the tag suggestion does not appear again when opening the app
    And the tag suggestion is available in the tag settings

  @TAG-8
  Scenario: The picker sorts by use in [today − 89, today] and breaks ties by normalized alphabetical order
    Given the tags "groceries, leisure, transport, apps, home, Açaí, bank, health"
    And the tag "groceries" is on 8 entries dated between 2026-01-10 and 2026-03-14
    And the tag "leisure" is on 5 entries dated between 2026-02-01 and 2026-03-10
    And the tag "transport" is on 5 entries dated between 2026-01-05 and 2026-03-15
    And the tag "apps" is on 1 entry on 2026-03-10 and on 1 planned entry on 2026-03-20
    And the tag "home" is on 1 entry on 2025-12-16
    And the tag "health" is on 12 entries, all dated up to 2025-12-15
    And the tags "Açaí" and "bank" are not on any entry
    When I open the entry's tag picker
    Then the tags appear in this order:
      | tag       | uses in window |
      | groceries | 8              |
      | leisure   | 5              |
      | transport | 5              |
      | apps      | 1              |
      | home      | 1              |
      | Açaí      | 0              |
      | bank      | 0              |
      | health    | 0              |

  @TAG-8 @edge
  Scenario Outline: Window boundary [2025-12-16, 2026-03-15]
    Given the tags "avocado, zebra"
    And the tag "zebra" is on 1 <status> entry on <date>
    And the tag "avocado" is not on any entry
    When I open the entry's tag picker
    Then the first tag in the picker is "<first>"

    Examples:
      | date       | status    | first   | reason                         |
      | 2025-12-15 | confirmed | avocado | today − 90: outside            |
      | 2025-12-16 | confirmed | zebra   | today − 89: inside             |
      | 2026-03-15 | confirmed | zebra   | today: inside                  |
      | 2026-03-16 | planned   | avocado | future planned: does not count |
