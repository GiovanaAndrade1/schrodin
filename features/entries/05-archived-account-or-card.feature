Feature: Entries and archived entities

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Itaú" of kind "checking" with opening balance R$ 50.00 on 2026-01-01
    And the expense "Fee" of R$ 50.00 in account "Itaú" on 2026-02-10, confirmed
    And the account "Itaú" is archived
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Retired" with limit R$ 1,000.00, closing day 1, due day 8, payment account "Nubank" and start date 2026-01-01
    And the purchase "Old" of R$ 100.00 on card "Retired" on 2026-02-05, with its statement paid
    And the card "Retired" is archived

  @LAN-9 @GER-5
  Scenario: Archived account and card do not appear in the picker
    When I open the new expense form
    Then the source picker shows "Nubank, Purple"

  @LAN-9 @error
  Scenario Outline: An entry cannot be created in an archived account or card
    When I add <entry> <source> on 2026-03-15
    Then the operation is blocked with the message "<message>"

    Examples:
      | entry                          | source            | message                                    |
      | the expense "Test" of R$ 10.00 | to account "Itaú" | An archived account doesn't accept entries |
      | the income "Test" of R$ 10.00  | to account "Itaú" | An archived account doesn't accept entries |
      | the expense "Test" of R$ 10.00 | to card "Retired" | An archived card doesn't accept entries    |
      | the refund "Test" of R$ 10.00  | to card "Retired" | An archived card doesn't accept entries    |

  @LAN-9 @GER-5
  Scenario: An entry of an archived account is still visible in the history
    When I open the ledger of account "Itaú"
    Then I see the expense "Fee" of R$ 50.00 on 2026-02-10

  @LAN-9 @CON-13 @error
  Scenario Outline: An entry of an archived account or card is read-only
    When I try to <action>
    Then the operation is blocked with the message "<message>"
    And the actual balance of account "Itaú" is R$ 0.00

    Examples:
      | action                                               | message                                                  |
      | edit the title of the expense "Fee" to "Package Fee" | Account 'Itaú' is archived. Unarchive it to make changes |
      | move the expense "Fee" to account "Nubank"           | Account 'Itaú' is archived. Unarchive it to make changes |
      | delete the expense "Fee"                             | Account 'Itaú' is archived. Unarchive it to make changes |
      | unconfirm the expense "Fee"                          | Account 'Itaú' is archived. Unarchive it to make changes |
      | delete the purchase "Old"                            | Card 'Retired' is archived. Unarchive it to make changes |

  @LAN-9 @CON-13 @CON-11
  Scenario: After unarchiving, the entry is editable again
    When I unarchive the account "Itaú"
    And I edit the title of the expense "Fee" to "Package Fee"
    Then there is the expense "Package Fee" in account "Itaú"
