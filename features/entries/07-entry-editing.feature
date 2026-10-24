Feature: Entry editing

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the projection horizon is 12 months

  @LAN-8 @CON-4
  Scenario: Changing the amount recalculates the actual balance
    Given the expense "Coffee" of R$ 8.50 in account "Nubank" on 2026-03-15, confirmed
    When I edit the expense "Coffee" to R$ 10.00
    Then the actual balance of account "Nubank" is R$ 990.00

  @LAN-8 @GER-4 @CON-4
  Scenario: Changing an expense to income reverses the effect without changing the sign
    Given the expense "Pix João" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed
    And the actual balance of account "Nubank" is R$ 880.00
    When I edit the expense "Pix João" switching the type to income
    Then there is the income "Pix João" of R$ 120.00
    And the actual balance of account "Nubank" is R$ 1,120.00

  @LAN-8 @CON-4
  Scenario: Moving between accounts takes from one and puts into the other
    Given the income "Freelance" of R$ 300.00 in account "Nubank" on 2026-03-10, confirmed
    When I edit the income "Freelance" moving it to account "Wallet"
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the actual balance of account "Wallet" is R$ 500.00

  @LAN-8 @CON-3 @error
  Scenario: Moving to an account whose opening date is after the entry date is blocked
    Given the income "Freelance" of R$ 300.00 in account "Nubank" on 2026-02-15, confirmed
    When I edit the income "Freelance" moving it to account "Wallet"
    Then the operation is blocked with the message "The date can't be before the opening balance of account Wallet (2026-03-01)"
    And the income "Freelance" is in account "Nubank"

  @LAN-8 @LAN-2 @LIM-1 @FAT-1
  Scenario: Moving an expense from the account to the card reallocates it to the statement
    Given the expense "Sneakers" of R$ 300.00 in account "Nubank" on 2026-03-10, confirmed
    When I edit the expense "Sneakers" moving it to card "Purple"
    Then the actual balance of account "Nubank" is R$ 1,000.00
    And the purchase "Sneakers" is in the 2026-04 statement of card "Purple"
    And the available limit of card "Purple" is R$ 4,700.00

  @LAN-8 @LIM-1
  Scenario: Moving a purchase from the card to the account removes it from the statement
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I edit the purchase "Sneakers" moving it to account "Nubank"
    Then the 2026-04 statement of card "Purple" has total R$ 0.00 and outstanding R$ 0.00
    And the available limit of card "Purple" is R$ 5,000.00
    And the actual balance of account "Nubank" is R$ 700.00
    And the expense "Sneakers" is "confirmed"

  @LAN-8 @FAT-1
  Scenario: Moving between cards recalculates the statement by the new card's cycle
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I edit the purchase "Sneakers" moving it to card "Black"
    Then the purchase "Sneakers" is in the 2026-04 statement of card "Black"
    And the 2026-04 statement of card "Black" closes on 2026-03-28 and is due on 2026-04-05
    And the available limit of card "Purple" is R$ 5,000.00
    And the available limit of card "Black" is R$ 9,700.00

  @LAN-8 @FAT-12 @edge
  Scenario: Moving to the card an expense whose date falls in an already closed statement warns
    Given the expense "Pharmacy" of R$ 80.00 in account "Nubank" on 2026-03-01, confirmed
    When I edit the expense "Pharmacy" moving it to card "Purple"
    Then I see the warning "this changes a statement that has already closed"
    And the purchase "Pharmacy" is in the 2026-03 statement of card "Purple"

  @LAN-8 @STA-6 @edge
  Scenario: An overdue planned account entry moved to the card becomes a confirmed purchase, with a warning
    Given the expense "Course" of R$ 400.00 in account "Nubank" on 2026-03-10, planned
    When I edit the expense "Course" moving it to card "Purple"
    Then I see the warning "The purchase 'Course' will be confirmed and already uses limit"
    And the purchase "Course" is "confirmed"
    And the available limit of card "Purple" is R$ 4,600.00

  @LAN-8 @STA-6
  Scenario: A future planned account entry moved to the card stays planned
    Given the expense "Course" of R$ 400.00 in account "Nubank" on 2026-03-20, planned
    When I edit the expense "Course" moving it to card "Purple"
    Then the purchase "Course" is "planned"
    And the available limit of card "Purple" is R$ 5,000.00

  @LAN-8 @FAT-1 @edge
  Scenario: Changing the purchase date across the closing date changes the statement
    Given the purchase "Ticket" of R$ 800.00 on card "Purple" on 2026-04-02
    And the purchase "Ticket" is in the 2026-04 statement of card "Purple"
    When I edit the purchase "Ticket" to date 2026-04-03
    Then the purchase "Ticket" is in the 2026-05 statement of card "Purple"

  @LAN-8 @LAN-7 @error
  Scenario Outline: Date editing respects the limits
    Given the expense "Rent" of R$ 1,500.00 in account "Wallet" on 2026-03-20, planned
    When I edit the expense "Rent" to date <date>
    Then the operation is blocked with the message "<message>"
    And the expense "Rent" is still on 2026-03-20

    Examples:
      | date       | message                                                                     |
      | 2026-02-28 | The date can't be before the opening balance of account Wallet (2026-03-01) |
      | 2027-03-16 | The date can't be after 2027-03-15                                          |

  @LAN-8 @STA-2 @STA-3 @edge
  Scenario: A planned entry edited to a past date stays planned and becomes overdue
    Given the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-03-20, planned
    When I edit the expense "Electricity" to date 2026-03-12
    Then the expense "Electricity" is "overdue"
    And the actual balance of account "Nubank" is R$ 1,000.00

  @LAN-8 @TRF-2
  Scenario Outline: A transfer does not change type; an expense only changes to income
    Given <entry>
    When I open the editing <target>
    Then the offered types are "<types>"

    Examples:
      | entry                                                                                                | target                   | types           |
      | the expense "Pix" of R$ 100.00 in account "Nubank" on 2026-03-15, confirmed                          | of the expense "Pix"     | expense, income |
      | the transfer "Change" of R$ 50.00 from account "Nubank" to account "Wallet" on 2026-03-15, confirmed | of the transfer "Change" | transfer        |

  @LAN-8 @LAN-3 @EST-1
  Scenario: A card purchase turned into money back becomes an unlinked refund
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    When I edit the purchase "Sneakers" switching it to money back
    Then the entry "Sneakers" is an unlinked refund on card "Purple"
    And the 2026-04 statement of card "Purple" has total -R$ 300.00 and outstanding -R$ 300.00
    And the available limit of card "Purple" is R$ 5,300.00

  @LAN-8 @EST-4 @EST-7 @error
  Scenario Outline: An entry with a linked refund or account refund does not change account, card or type
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    And the expense "Headphones" of R$ 200.00 in account "Nubank" on 2026-03-05, confirmed
    And the account refund "Headphones" of R$ 50.00 in account "Nubank" on 2026-03-12 linked to the expense "Headphones"
    When I edit <entry> <change>
    Then the operation is blocked with the message "<message>"

    Examples:
      | entry                    | change                        | message                                 |
      | the purchase "Sneakers"  | moving it to account "Nubank" | Delete the linked refunds first         |
      | the purchase "Sneakers"  | moving it to card "Black"     | Delete the linked refunds first         |
      | the purchase "Sneakers"  | switching it to money back    | Delete the linked refunds first         |
      | the expense "Headphones" | moving it to account "Wallet" | Delete the linked account refunds first |
      | the expense "Headphones" | moving it to card "Purple"    | Delete the linked account refunds first |
      | the expense "Headphones" | switching the type to income  | Delete the linked account refunds first |

  @LAN-8 @EST-4
  Scenario: An entry with a linked refund can still change title and tags
    Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10
    And the refund "Sneakers" of R$ 100.00 on card "Purple" on 2026-03-12 linked to the purchase "Sneakers"
    When I edit the title of the purchase "Sneakers" to "Running Sneakers"
    Then there is the purchase "Running Sneakers" on card "Purple"

  @LAN-8 @AJU-5 @error
  Scenario: An adjustment only has the note editable
    Given I adjusted the balance of account "Nubank" to R$ 950.00
    When I edit the note of the 2026-03-15 adjustment of account "Nubank" to "bank difference"
    Then the 2026-03-15 adjustment of account "Nubank" has the note "bank difference"
    When I try to edit the amount of the 2026-03-15 adjustment of account "Nubank" to R$ 40.00
    Then the operation is blocked with the message "An adjustment can't be edited. Delete it and adjust again"

  @LAN-8 @GER-6
  Scenario: Editing keeps the creation date and updates the modification date
    Given it is now 2026-03-10 09:00 in the user's time zone
    And the expense "Coffee" of R$ 8.50 in account "Nubank" on 2026-03-10, confirmed
    And it is now 2026-03-15 18:00 in the user's time zone
    When I edit the expense "Coffee" to R$ 9.00
    Then the expense "Coffee" shows "Created on 2026-03-10 09:00"
    And the expense "Coffee" was changed on 2026-03-15 18:00
