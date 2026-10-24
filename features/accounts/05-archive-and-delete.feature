Feature: Account archiving and deletion

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 0.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And "Nubank" is the default account

  @CON-8 @GER-5
  Scenario: Delete an account with no entries and no card
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    When I delete the account "Itaú"
    Then the account "Itaú" does not exist
    And I can create the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01

  @CON-8 @GER-5 @error
  Scenario Outline: An account with any entry cannot be deleted, only archived
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And <entry>
    When I delete the account "Itaú"
    Then the operation is blocked with the message "This account has entries. Archive it instead of deleting"
    And I see the option "Archive"

    Examples:
      | entry                                                                                              |
      | the expense "Bakery" of R$ 20.00 in account "Itaú" on 2026-03-02, confirmed                        |
      | the income "Freelance" of R$ 800.00 in account "Itaú" on 2026-04-10, planned                       |
      | the transfer "Top-up" of R$ 50.00 from account "Nubank" to account "Itaú" on 2026-03-05, confirmed |
      | the outflow adjustment of R$ 5.00 in account "Itaú" on 2026-03-10                                  |

  @CON-8 @edge
  Scenario: After deleting all entries, the account can be deleted
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the expense "Bakery" of R$ 20.00 in account "Itaú" on 2026-03-02, confirmed
    When I delete the expense "Bakery"
    And I delete the account "Itaú"
    Then the account "Itaú" does not exist

  @CON-8 @CAR-3 @error
  Scenario: The payment account of an active card cannot be deleted
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Itaú"
    When I delete the account "Itaú"
    Then the operation is blocked with the message "This account pays card Black. Change the card's account first"

  @CON-8 @CAR-7 @edge
  Scenario: The payment account of an archived card can be deleted
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the archived card "Black" with payment account "Itaú" and no entries
    When I delete the account "Itaú"
    Then the account "Itaú" does not exist
    When I unarchive the card "Black"
    Then I see the warning "Choose the payment account for card Black"

  @CON-8 @edge
  Scenario: Deleting an account with no entries but with an opening balance asks for confirmation showing the balance
    Given the account "Itaú" of kind "checking" with opening balance R$ 250.00 on 2026-03-01
    When I delete the account "Itaú"
    Then I see the warning "Account Itaú has a balance of R$ 250.00, which will leave your consolidated balance"
    When I confirm the warning
    Then the account "Itaú" does not exist

  @CON-8 @CON-10 @error
  Scenario: Deleting the default account requires choosing another one first
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And "Itaú" is the default account
    When I delete the account "Itaú"
    Then I am required to choose the new default account among "Nubank, Wallet"

  @CON-9 @GER-5
  Scenario: Archive a zeroed account with no pending items
    Given the expense "Market" of R$ 80.00 in account "Wallet" on 2026-02-10, confirmed
    And the income "Change" of R$ 80.00 in account "Wallet" on 2026-02-11, confirmed
    When I archive the account "Wallet"
    Then the account "Wallet" is archived
    And the account "Wallet" does not appear in the account list
    And the account "Wallet" does not appear in the account picker when adding an entry

  @CON-9 @error @edge
  Scenario Outline: Archiving requires an actual balance of exactly zero
    Given the account "Itaú" of kind "checking" with opening balance <balance> on 2026-03-01
    When I archive the account "Itaú"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item         | offered action       |
      | Balance of <balance> | Transfer the balance |

    Examples:
      | balance   |
      | R$ 0.01   |
      | -R$ 0.01  |
      | R$ 350.00 |

  @CON-9 @error
  Scenario: Archiving with a future planned entry is blocked
    Given the income "Freelance" of R$ 800.00 in account "Wallet" on 2026-04-10, planned
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                      | offered action                   |
      | Planned "Freelance" on 2026-04-10 | Move or delete the planned entry |

  @CON-9 @STA-3 @error
  Scenario: Archiving with an overdue entry is blocked
    Given the expense "Gas" of R$ 120.00 in account "Wallet" on 2026-03-10, planned
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                | offered action                   |
      | Overdue "Gas" on 2026-03-10 | Move or delete the planned entry |

  @CON-9 @error @edge
  Scenario: A planned entry dated today also blocks archiving
    Given the expense "Gas" of R$ 120.00 in account "Wallet" on 2026-03-15, planned
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"

  @CON-9 @REC-1 @error
  Scenario: The destination account of an active recurring series cannot be archived
    Given the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-04-01, with no end
    When I archive the account "Reserve"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                   | offered action |
      | Recurring series "Save" active | End the series |

  @CON-9 @REC-2 @edge
  Scenario: A recurring series that has already ended does not block
    Given the recurring income "Allowance" of R$ 100.00 in account "Wallet", monthly, starting 2026-01-05, until 2026-02-05
    And all occurrences of series "Allowance" are "confirmed"
    And the expense "Market" of R$ 200.00 in account "Wallet" on 2026-02-20, confirmed
    When I archive the account "Wallet"
    Then the account "Wallet" is archived

  @CON-9 @CAR-3 @error
  Scenario: The payment account of an active card cannot be archived
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Itaú"
    When I archive the account "Itaú"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item      | offered action            |
      | Pays card "Black" | Change the card's account |

  @CON-9 @DIA-10 @error
  Scenario: An account chosen as the daily budget source cannot be archived
    Given the daily budget source is account "Wallet"
    When I archive the account "Wallet"
    Then the operation is blocked with the message "Resolve the pending items before archiving"
    And I see the pending items:
      | pending item                  | offered action                 |
      | It is the daily budget source | Change the daily budget source |

  @CON-9 @CAR-3
  Scenario: Changing the card's account allows archiving
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Itaú"
    When I change the default payment account of card "Black" to "Nubank"
    And I archive the account "Itaú"
    Then the account "Itaú" is archived

  @CON-9 @error
  Scenario: All pending items show up together
    Given the account "Itaú" of kind "checking" with opening balance R$ 350.00 on 2026-03-01
    And the expense "Gas" of R$ 120.00 in account "Itaú" on 2026-03-10, planned
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Itaú"
    When I archive the account "Itaú"
    Then I see the pending items:
      | pending item                | offered action                   |
      | Balance of R$ 350.00        | Transfer the balance             |
      | Overdue "Gas" on 2026-03-10 | Move or delete the planned entry |
      | Pays card "Black"           | Change the card's account        |

  @CON-9 @TRF-7 @PRJ-5
  Scenario: Transferring the balance through the archive flow zeroes the account without changing the consolidated balance
    Given the account "Itaú" of kind "checking" with opening balance R$ 350.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the consolidated projected balance on 2026-03-15 is R$ 1,350.00
    When I archive the account "Itaú"
    And I choose "Transfer the balance" for account "Nubank"
    Then there is the transfer of R$ 350.00 from account "Itaú" to account "Nubank" on 2026-03-15, confirmed
    And the account "Itaú" is archived
    And the actual balance of account "Nubank" is R$ 1,350.00
    And the consolidated projected balance on 2026-03-15 is R$ 1,350.00

  @CON-9 @edge
  Scenario: Transferring the balance of a negative account covers the hole from another account
    Given the account "Itaú" of kind "checking" with opening balance -R$ 40.00 on 2026-03-01
    When I archive the account "Itaú"
    And I choose "Transfer the balance" from account "Nubank"
    Then there is the transfer of R$ 40.00 from account "Nubank" to account "Itaú" on 2026-03-15, confirmed
    And the account "Itaú" is archived
    And the actual balance of account "Nubank" is R$ 960.00

  @CON-9 @CON-3 @error
  Scenario: Moving a planned entry to resolve a pending item respects the destination account's opening date
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-03-12
    And the expense "Gas" of R$ 120.00 in account "Wallet" on 2026-03-10, planned
    When I archive the account "Wallet"
    And I choose "Move or delete the planned entry" and move "Gas" to account "Itaú"
    Then the operation is blocked with the message "The date can't be before the opening balance of account Itaú (2026-03-12)"
    And the account "Wallet" is active

  @CON-9 @AJU-1
  Scenario: An adjustment can zero the account and allow archiving
    Given the income "Change" of R$ 12.50 in account "Wallet" on 2026-03-01, confirmed
    When I adjust the balance of account "Wallet" to R$ 0.00
    And I archive the account "Wallet"
    Then the account "Wallet" is archived

  @CON-10 @error
  Scenario: Archiving the default account requires choosing another one first
    Given the expense "Rent" of R$ 1,000.00 in account "Nubank" on 2026-03-05, confirmed
    When I archive the account "Nubank"
    Then I am required to choose the new default account among "Wallet"
    When I choose "Wallet" as the new default account
    Then the account "Nubank" is archived
    And "Wallet" is the default account
    And the daily budget source is account "Wallet"

  @CON-10 @edge
  Scenario: Archiving the default when only a saving account is left leaves the app with no default
    Given the expense "Rent" of R$ 1,000.00 in account "Nubank" on 2026-03-05, confirmed
    And I archived the account "Wallet"
    When I archive the account "Nubank"
    Then the account "Nubank" is archived
    And there is no default account
    And the account "Reserve" is active

  @GER-5 @IND-2
  Scenario: An archived account stays in reports and history
    Given the expense "Market" of R$ 80.00 in account "Wallet" on 2026-02-10, confirmed
    And the income "Change" of R$ 80.00 in account "Wallet" on 2026-02-11, confirmed
    And the realized Outflows for 2026-02 are R$ 80.00
    When I archive the account "Wallet"
    Then the realized Outflows for 2026-02 are R$ 80.00
    And I can open the ledger of the archived account "Wallet" with the expense "Market"

  @GER-7 @GER-5
  Scenario Outline: Export includes archived accounts and their entries
    Given the archived account "Old" of kind "checking" with the expense "Market" of R$ 80.00 on 2026-02-10, confirmed
    When I export all my data as "<format>"
    Then the exported file has the account "Old" marked as archived
    And the exported file has the expense "Market" of R$ 80.00 on 2026-02-10, confirmed, in account "Old"

    Examples:
      | format |
      | CSV    |
      | JSON   |

  @GER-5 @LAN-9 @AJU-1 @error
  Scenario Outline: Nothing new goes into an archived account
    Given the archived account "Old" of kind "checking"
    When I try to <action>
    Then the operation is blocked with the message "Account Old is archived"

    Examples:
      | action                                                                                     |
      | add the expense "Coffee" of R$ 8.50 to account "Old" on 2026-03-15                         |
      | add the income "Pix" of R$ 50.00 to account "Old" on 2026-03-15                            |
      | add the transfer "Top-up" of R$ 50.00 from account "Nubank" to account "Old" on 2026-03-15 |
      | adjust the balance of account "Old" to R$ 10.00                                            |
      | set "Old" as the default account                                                           |

  @CON-13 @LAN-9 @error
  Scenario Outline: An archived account and its entries are read-only
    Given the archived account "Old" of kind "checking" with the expense "Market" of R$ 80.00 on 2026-02-10, confirmed
    When I try to <action>
    Then the operation is blocked with the message "Unarchive the account to edit it"

    Examples:
      | action                                              |
      | rename the account "Old" to "Aged"                  |
      | change the opening balance of account "Old"         |
      | change the purpose of account "Old"                 |
      | edit the amount of the expense "Market" to R$ 90.00 |
      | delete the expense "Market"                         |
