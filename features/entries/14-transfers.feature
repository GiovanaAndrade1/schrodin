Feature: Transfers between accounts, statement payment and credit withdrawal

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 2,000.00 on 2026-01-01
    And the account "Savings" of kind "savings" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 12 months

  @TRF-1 @TRF-2 @CON-4 @INV-2
  Scenario: A confirmed transfer leaves one account and enters the other
    When I add the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 900.00
    And the actual balance of account "Wallet" is R$ 300.00
    And the sum of the actual balances of all accounts is R$ 3,200.00

  @TRF-1 @error
  Scenario: Same source and destination is blocked
    When I add the transfer "Nothing" of R$ 100.00 from account "Nubank" to account "Nubank" on 2026-03-15
    Then the operation is blocked with the message "Source and destination must be different"

  @TRF-1 @LAN-9 @error
  Scenario Outline: A transfer involving an archived account or card is blocked
    Given the account "Itaú" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    And the account "Itaú" is archived
    And the card "Retired" with limit R$ 1,000.00, closing day 1, due day 8, payment account "Nubank" and start date 2026-01-01
    And the card "Retired" is archived
    When I add the transfer "Test" of R$ 10.00 <from> to <to> on 2026-03-15
    Then the operation is blocked with the message "<message>"

    Examples:
      | from                  | to               | message                                    |
      | from account "Itaú"   | account "Nubank" | Account 'Itaú' is archived. Unarchive it to make changes |
      | from account "Nubank" | account "Itaú"   | Account 'Itaú' is archived. Unarchive it to make changes |
      | from account "Nubank" | card "Retired"   | Card 'Retired' is archived. Unarchive it to make changes |

  @TRF-1 @FAT-7 @TRF-3 @IND-2
  Scenario: A transfer to the card pays the statement and is not an expense
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 700.00
    And the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the realized Outflows for 2026-03 are R$ 300.00

  @TRF-7 @FAT-6 @PRJ-6
  Scenario: Paying the statement early does not count the outflow twice in the projection
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00
    When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 700.00
    And the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00

  @TRF-2
  Scenario: Editing the amount changes both sides
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I edit the transfer "Change" to R$ 150.00
    Then the actual balance of account "Nubank" is R$ 850.00
    And the actual balance of account "Wallet" is R$ 350.00

  @TRF-2 @LAN-8
  Scenario: Changing the destination takes from one account and puts into the other
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I edit the transfer "Change" switching the destination to account "Reserve"
    Then the actual balance of account "Nubank" is R$ 900.00
    And the actual balance of account "Wallet" is R$ 200.00
    And the actual balance of account "Reserve" is R$ 2,100.00

  @TRF-1 @TRF-2 @error
  Scenario: Editing to a source equal to the destination is blocked
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I edit the transfer "Change" switching the destination to account "Nubank"
    Then the operation is blocked with the message "Source and destination must be different"

  @TRF-2 @GER-5
  Scenario: Deleting from the ledger of one side deletes both
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I open the ledger of account "Wallet"
    And I delete the transfer "Change" and confirm
    Then the transfer "Change" does not appear in the ledger of account "Nubank"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the actual balance of account "Wallet" is R$ 200.00

  @TRF-2
  Scenario: There is no option to delete only one side
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    When I open the actions of the transfer "Change" in the ledger of account "Wallet"
    Then the offered actions are "edit, delete, unconfirm"

  @TRF-5 @CON-4 @PRJ-3
  Scenario: A planned transfer stays planned on both sides
    When I add the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-20
    Then the transfer "Change" is "planned" in account "Nubank" and in account "Wallet"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the actual balance of account "Wallet" is R$ 200.00
    And the projected balance of account "Nubank" on 2026-03-20 is R$ 900.00
    And the projected balance of account "Wallet" on 2026-03-20 is R$ 300.00

  @TRF-5 @STA-3 @STA-5
  Scenario: Confirming an overdue transfer confirms both sides
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-10, planned
    And the transfer "Change" is "overdue" in account "Nubank" and in account "Wallet"
    When I confirm the transfer "Change" with amount R$ 100.00 on 2026-03-10
    Then the transfer "Change" is "confirmed" in account "Nubank" and in account "Wallet"
    And the actual balance of account "Nubank" is R$ 900.00
    And the actual balance of account "Wallet" is R$ 300.00

  @TRF-5 @STA-9
  Scenario: Unconfirming a transfer unconfirms both sides
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-10, confirmed
    When I unconfirm the transfer "Change"
    Then the transfer "Change" is "overdue" in account "Nubank" and in account "Wallet"
    And the actual balance of account "Nubank" is R$ 1,000.00
    And the actual balance of account "Wallet" is R$ 200.00

  @TRF-6 @CON-3 @edge
  Scenario Outline: The date respects the opening date of both sides
    When I add the transfer "Test" of R$ 10.00 <from> to <to> on <date>
    Then the result is "<result>"

    Examples:
      | from                  | to               | date       | result                                                                               |
      | from account "Nubank" | account "Wallet" | 2026-03-01 | accepted                                                                             |
      | from account "Nubank" | account "Wallet" | 2026-02-28 | blocked: The date can't be before the opening balance of account Wallet (2026-03-01) |
      | from account "Wallet" | account "Nubank" | 2026-02-28 | blocked: The date can't be before the opening balance of account Wallet (2026-03-01) |
      | from account "Nubank" | card "Purple"    | 2026-01-01 | accepted                                                                             |
      | from account "Nubank" | card "Purple"    | 2025-12-31 | blocked: The date can't be before the opening balance of account Nubank (2026-01-01) |

  @TRF-6 @CAR-8 @FAT-7 @error
  Scenario: A statement payment cannot be before the card's start date
    Given the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-03-01
    When I add the transfer "Black Payment" of R$ 100.00 from account "Nubank" to card "Black" on 2026-02-20
    Then the operation is blocked with the message "The date can't be before the card's start (2026-03-01)"

  @TRF-6 @LAN-8 @error
  Scenario: Editing the transfer date respects both sides
    Given the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-05, confirmed
    When I edit the transfer "Change" to date 2026-02-20
    Then the operation is blocked with the message "The date can't be before the opening balance of account Wallet (2026-03-01)"

  @TRF-3 @IND-1 @IND-2 @IND-5
  Scenario: A transfer does not go into Inflows, Outflows or Performance
    When I add the transfer "Change" of R$ 100.00 from account "Nubank" to account "Wallet" on 2026-03-15
    And I add the transfer "Withdrawal" of R$ 200.00 from account "Reserve" to account "Nubank" on 2026-03-15
    Then the realized Inflows for 2026-03 are R$ 0.00
    And the realized Outflows for 2026-03 are R$ 0.00
    And the realized Performance for 2026-03 is R$ 0.00

  @TRF-4 @IND-6
  Scenario Outline: Transfer effect on Saved
    When I add the transfer "Test" of R$ 500.00 <from> to <to> on 2026-03-15
    Then the realized Saved for 2026-03 is <saved>

    Examples:
      | from                   | to                | saved      |
      | from account "Nubank"  | account "Reserve" | R$ 500.00  |
      | from account "Reserve" | account "Nubank"  | -R$ 500.00 |
      | from account "Nubank"  | account "Wallet"  | R$ 0.00    |
      | from account "Reserve" | account "Savings" | R$ 0.00    |
      | from account "Nubank"  | card "Purple"     | R$ 0.00    |
      | from account "Reserve" | card "Purple"     | -R$ 500.00 |

  @TRF-4 @IND-6
  Scenario: Saving and withdrawing in the same month offset each other
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-05, confirmed
    And the transfer "Withdrawal" of R$ 200.00 from account "Reserve" to account "Nubank" on 2026-03-10, confirmed
    Then the realized Saved for 2026-03 is R$ 300.00

  @TRF-4 @TRF-5 @IND-11
  Scenario: A planned transfer to saving only goes into forecast Saved
    Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-05, confirmed
    And the transfer "Save More" of R$ 300.00 from account "Nubank" to account "Reserve" on 2026-03-25, planned
    Then the realized Saved for 2026-03 is R$ 500.00
    And the forecast Saved for 2026-03 is R$ 800.00

  @TRF-7 @CON-6 @PRJ-5
  Scenario Outline: Effect on the consolidated actual balance
    Given the consolidated actual balance is R$ 1,200.00
    When I add the transfer "Test" of R$ 300.00 <from> to <to> on 2026-03-15
    Then the consolidated actual balance is <consolidated>

    Examples:
      | from                   | to                | consolidated |
      | from account "Nubank"  | account "Wallet"  | R$ 1,200.00  |
      | from account "Nubank"  | account "Reserve" | R$ 900.00    |
      | from account "Nubank"  | card "Purple"     | R$ 900.00    |
      | from account "Reserve" | account "Nubank"  | R$ 1,500.00  |
      | from account "Reserve" | account "Savings" | R$ 1,200.00  |

  @TRF-1 @LAN-1 @LAN-4 @error
  Scenario: A transfer follows the same amount validations
    When I type "100−100" in the amount
    And I save the transfer "Change" from account "Nubank" to account "Wallet" on 2026-03-15
    Then the operation is blocked with the message "The amount must be greater than zero"

  @TRF-8 @LIM-1 @TRF-3 @TRF-7
  Scenario: Withdrawing the card credit to an account
    Given the refund "Store Credit" of R$ 700.00 on card "Purple" on 2026-03-15, unlinked
    And the available limit of card "Purple" is R$ 5,700.00
    When I withdraw R$ 700.00 of credit from card "Purple" to account "Nubank" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 1,700.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the 2026-04 statement of card "Purple" has total -R$ 700.00 and outstanding R$ 0.00
    And the consolidated actual balance is R$ 1,900.00
    And the realized Inflows for 2026-03 are R$ 0.00

  @TRF-8 @edge @error
  Scenario Outline: Withdrawal only up to the available credit
    Given the refund "Store Credit" of R$ <credit> on card "Purple" on 2026-03-15, unlinked
    When I withdraw R$ <withdrawal> of credit from card "Purple" to account "Nubank" on 2026-03-15
    Then the result is "<result>"

    Examples:
      | credit | withdrawal | result                                                   |
      | 700.00 | 700.00     | accepted                                                 |
      | 700.00 | 700.01     | blocked: You can only withdraw up to R$ 700.00 of credit |
      | 700.00 | 300.00     | accepted                                                 |

  @TRF-8 @CAR-8 @edge @error
  Scenario Outline: Withdrawal date: only confirmed and not before the card's start date
    Given I changed the start date of card "Purple" to 2026-03-01
    And the refund "Store Credit" of R$ 700.00 on card "Purple" on 2026-03-02, unlinked
    When I withdraw R$ 100.00 of credit from card "Purple" to account "Nubank" on <date>
    Then the result is "<result>"

    Examples:
      | date       | result                                                          |
      | 2026-03-15 | accepted                                                        |
      | 2026-03-16 | blocked: A credit withdrawal can't be scheduled                 |
      | 2026-02-28 | blocked: The date can't be before the card's start (2026-03-01) |

  @TRF-8 @TRF-7 @CON-6
  Scenario: A withdrawal to a saving account does not go into the consolidated balance
    Given the refund "Store Credit" of R$ 700.00 on card "Purple" on 2026-03-15, unlinked
    When I withdraw R$ 700.00 of credit from card "Purple" to account "Reserve" on 2026-03-15
    Then the actual balance of account "Reserve" is R$ 2,700.00
    And the consolidated actual balance is R$ 1,200.00

  @TRF-8 @TRF-1 @error
  Scenario: A card with no credit cannot be a transfer source
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I withdraw R$ 100.00 of credit from card "Purple" to account "Nubank" on 2026-03-15
    Then the operation is blocked with the message "Card 'Purple' has no credit to withdraw"
