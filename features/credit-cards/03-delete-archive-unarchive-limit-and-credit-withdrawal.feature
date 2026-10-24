Feature: Card deletion, archiving, unarchiving, limit change and credit withdrawal

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01

  @CAR-4
  Scenario: A card with no entries is deleted
    When I delete the card "Purple"
    Then the card "Purple" no longer exists

  @CAR-4 @GER-5 @error
  Scenario: A card with entries cannot be deleted, only archived
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I delete the card "Purple"
    Then the operation is blocked with the message "This card has entries. Archive it instead of deleting."

  @CAR-4 @GER-5
  Scenario: A paid-off card is archived
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the payment of R$ 200.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I archive the card "Purple"
    Then the card "Purple" is archived
    And the card "Purple" does not appear in the card picker
    And the 2026-03 statement of card "Purple" is still in the history with total R$ 200.00

  @CAR-4 @LIM-1 @error
  Scenario: Archiving requires zero total debt
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I archive the card "Purple"
    Then the operation is blocked with the message "The card still has a debt of R$ 300.00"

  @CAR-4 @STA-6 @error
  Scenario Outline: Archiving with a planned entry tied to the card is blocked, even with no debt
    Given <planned>
    And the total debt of card "Purple" is R$ 0.00
    When I archive the card "Purple"
    Then the operation is blocked with the message "<message>"

    Examples:
      | planned                                                                                                         | message                                     |
      | the purchase "Concert" of R$ 150.00 on card "Purple" on 2026-03-20                                              | The card has planned purchases: Concert     |
      | the refund "Reimbursement" of R$ 40.00 on card "Purple" on 2026-03-20                                           | The card has planned refunds: Reimbursement |
      | the payment of R$ 100.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, planned | The card has planned payments               |

  @CAR-4 @REC-9 @error
  Scenario: Archiving with an active recurrence is blocked
    Given the recurring expense "Netflix" of R$ 55.90 on card "Purple", monthly, starting 2026-04-20, with no end
    When I archive the card "Purple"
    Then the operation is blocked with the message "The card has active recurring series: Netflix"

  @CAR-4 @FAT-10 @TRF-8 @error
  Scenario: Archiving with credit is blocked and the app offers to withdraw it
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the payment of R$ 250.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    And the total debt of card "Purple" is -R$ 50.00
    When I archive the card "Purple"
    Then the operation is blocked with the message "The card has a credit of R$ 50.00. Withdraw the credit before archiving."
    And I see the option "Withdraw credit"

  @TRF-8 @LIM-1 @CAR-4 @TRF-7
  Scenario: Withdrawing the credit zeroes the debt and allows archiving
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the payment of R$ 250.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    And the daily amount is R$ 0.00 since 2026-01-01
    And the actual balance of account "Nubank" is R$ 750.00
    When I withdraw R$ 50.00 of credit from card "Purple" to account "Nubank" on 2026-03-15
    Then the actual balance of account "Nubank" is R$ 800.00
    And the total debt of card "Purple" is R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the 2026-04 statement of card "Purple" has total -R$ 50.00 and outstanding R$ 0.00
    And the consolidated projected balance on 2026-03-15 is R$ 800.00
    When I archive the card "Purple"
    Then the card "Purple" is archived

  @TRF-8 @CAR-8 @error @edge
  Scenario Outline: Withdrawal is only allowed up to the available credit, confirmed and within the dates
    Given the purchase "Dinner" of R$ 200.00 on card "Purple" on 2026-02-20
    And the payment of <paid> of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-08, confirmed
    When I withdraw <withdrawal> of credit from card "Purple" to account "Nubank" on <date>
    Then the operation is blocked with the message "<message>"

    Examples:
      | paid      | withdrawal | date       | message                                                |
      | R$ 250.00 | R$ 50.01   | 2026-03-15 | You can only withdraw up to R$ 50.00 of credit         |
      | R$ 200.00 | R$ 10.00   | 2026-03-15 | Card 'Purple' has no credit to withdraw                |
      | R$ 250.00 | R$ 50.00   | 2026-03-16 | A credit withdrawal can't be scheduled                 |
      | R$ 250.00 | R$ 50.00   | 2025-12-31 | The date can't be before the card's start (2026-01-01) |

  @LAN-9 @GER-5 @error
  Scenario: A purchase cannot be added to an archived card
    Given the card "Purple" is archived
    When I add the purchase "Coffee" of R$ 8.50 to card "Purple" on 2026-03-15
    Then the operation is blocked with the message "An archived card doesn't accept entries"

  @CAR-7 @CON-11
  Scenario: A card with no name collision is unarchived
    Given the card "Purple" is archived
    When I unarchive the card "Purple"
    Then the card "Purple" is active

  @CAR-7 @CON-11 @error
  Scenario: Unarchiving with a name already used by an active card asks for a rename
    Given the card "Purple" is archived
    And the card "purple" with limit R$ 2,000.00, closing day 15, due day 22 and payment account "Nubank"
    When I unarchive the card "Purple"
    Then I see the warning "An active card with this name already exists. Choose another name to unarchive."
    And the card "Purple" is archived

  @CAR-7 @CAR-3 @CON-8
  Scenario: Unarchiving requires a valid payment account
    Given the account "Wallet" of kind "cash" with opening balance R$ 500.00 on 2026-01-01
    And the card "Purple" is archived
    And the transfer "Empty Out" of R$ 1,000.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed
    And "Wallet" is the default account
    And the account "Nubank" is archived
    When I unarchive the card "Purple"
    Then I see the warning "Choose an active spending payment account"
    And the card "Purple" is archived
    When I unarchive the card "Purple" with payment account "Wallet"
    Then the card "Purple" is active
    And the default payment account of card "Purple" is "Wallet"

  @CAR-6 @LIM-1 @edge
  Scenario: Reducing the limit below the debt is allowed with a warning
    Given the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments
    When I change the limit of card "Purple" to R$ 2,000.00
    Then I see the warning "The limit is now lower than the current debt"
    And the available limit of card "Purple" is -R$ 1,000.00
