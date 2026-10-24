Feature: Calendar, time zone and horizon edges

  @integration @TER-4 @IND-8 @GER-10 @PRJ-4 @edge
  Scenario: The relative thermometer changes the color of the same balance at the year rollover
    Given today is 2026-12-31
    And the account "Nubank" of kind "checking" with actual balance R$ 1,500.00 and no planned entries
    And the daily amount is R$ 0.00 since 2026-09-01
    And the thermometer is in relative mode with the default multipliers
    And the realized Total outflows were:
      | month   | Total outflows |
      | 2026-09 | R$ 2,600.00    |
      | 2026-10 | R$ 3,000.00    |
      | 2026-11 | R$ 3,200.00    |
      | 2026-12 | R$ 4,000.00    |
    Then the cost of living is R$ 2,933.33
    And the thermometer thresholds are "-R$ 366.67 · R$ 0.00 · R$ 733.33 · R$ 1,466.67"
    And the thermometer color on 2026-12-31 is "dark green"
    And the thermometer color on 2027-01-01 is "dark green"
    When the day turns to 2027-01-01
    Then the cost of living is R$ 3,400.00
    And the thermometer thresholds are "-R$ 425.00 · R$ 0.00 · R$ 850.00 · R$ 1,700.00"
    And the consolidated projected balance on 2027-01-01 is R$ 1,500.00
    And the thermometer color on 2027-01-01 is "light green"

  @integration @REC-3 @CAR-2 @FAT-1 @FAT-3 @PAR-1 @GER-12 @IND-2 @edge
  Scenario Outline: The end of February ties together recurrence, statement, accrual and horizon
    Given today is <year>-01-31
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on <year>-01-01
    And the card "End" with limit R$ 5,000.00, closing day 30, due day 10, payment account "Nubank" and start date <year>-01-01
    And the projection horizon is 1 month
    And the recurring expense "Gym" of R$ 100.00 on card "End", monthly, starting <year>-01-31, with no end
    And the purchase "Course" of R$ 300.00 on card "End" on <year>-01-31 in 3 installments
    Then the horizon end is <feb>
    And the <year>-03 statement of card "End" closes on <feb> and is due on <year>-03-10
    And the <year>-01-31 occurrence of series "Gym" is "confirmed" in the <year>-03 statement
    And the <feb> occurrence of series "Gym" exists, is "planned" and falls in the <year>-04 statement, because it is the closing day
    And there is no occurrence of series "Gym" on <year>-03-31 yet
    And the installments of the purchase "Course" are:
      | k | statement | accrual      |
      | 1 | <year>-03 | <year>-01-31 |
      | 2 | <year>-04 | <feb>        |
      | 3 | <year>-05 | <year>-03-31 |
    And the derived outflow of the <year>-03 statement is left out of the projection, because it is due after <feb>

    Examples:
      | year | feb        |
      | 2027 | 2027-02-28 |
      | 2028 | 2028-02-29 |

  @integration @GER-3 @FAT-1 @DIA-5 @STA-6 @edge
  Scenario: A late-night purchase on the day before the closing date uses the local date
    Given the user's time zone is "America/Sao_Paulo"
    And today is 2026-04-02
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the tag "groceries" that marks daily spending
    And the purchase "Newspaper" of R$ 15.00 on card "Purple" on 2026-04-03
    When it is 23:30 on 2026-04-02 in São Paulo (02:30 on 2026-04-03 in UTC)
    And I add the purchase "Pizza" of R$ 70.00 to card "Purple" with the default date and the tag "groceries"
    Then the purchase "Pizza" has date 2026-04-02 and is in the 2026-04 statement
    And the daily reserve on 2026-04-02 is R$ 0.00
    And the daily budget from 2026-04-02 to 2026-04-02 has budgeted R$ 50.00, spent R$ 70.00 and overspend R$ 20.00
    And the purchase "Newspaper" is still "planned"
    When it is 00:00 on 2026-04-03 in São Paulo
    Then today is 2026-04-03
    And the 2026-04 statement of card "Purple" is "closed" with the purchase "Pizza"
    And the purchase "Newspaper" is "confirmed" in the 2026-05 statement

  @integration @GER-3 @INV-6 @STA-8 @DIA-5 @edge
  Scenario: Changing the time zone westward after midnight leaves a confirmed entry "tomorrow"
    Given the user's time zone is "America/Sao_Paulo"
    And it is now 2026-03-16 00:20 in the user's time zone
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the tag "groceries" that marks daily spending
    And I add the purchase "Snack" of R$ 30.00 to card "Purple" with the default date and the tag "groceries"
    And the purchase "Snack" has date 2026-03-16 and is "confirmed"
    # 23:20 on 2026-03-15 in Manaus
    When I change the time zone to "America/Manaus"
    Then I see the confirmation prompt "Changing the time zone changes today's date. No entry date will be changed"
    When I confirm the time zone change
    Then today is 2026-03-15
    And the purchase "Snack" still has date 2026-03-16 and is "confirmed"
    And I see the warning "1 confirmed entry now has tomorrow's date in the new time zone"
    And INV-6 still holds through the exception of up to 1 day after switching the time zone westward
    And the daily reserve on 2026-03-15 is R$ 50.00
    And the daily reserve on 2026-03-16 is R$ 20.00
    And the consolidated projected balance on 2026-03-15 is R$ 1,950.00
    And the consolidated projected balance on 2026-03-16 is R$ 1,930.00

  @integration @FAT-1 @FAT-5 @FAT-7 @FAT-13 @REC-9 @EST-1 @edge
  Scenario Outline: On the closing day, what is added today goes to the next statement
    Given today is 2026-04-03
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the recurring expense "Newspaper" of R$ 15.00 on card "Purple", monthly, starting 2026-03-03, with no end
    When <action>
    Then <item> is in the 2026-05 statement of card "Purple"

    Examples:
      | action                                                                          | item                                            |
      | I add the purchase "Coffee" of R$ 10.00 to card "Purple" on 2026-04-03          | the purchase "Coffee"                           |
      | I add the unlinked refund "Cashback" of R$ 10.00 to card "Purple" on 2026-04-03 | the refund "Cashback"                           |
      | the 2026-04-03 occurrence of series "Newspaper" confirms itself                 | the 2026-04-03 occurrence of series "Newspaper" |

  @integration @FAT-5 @FAT-7 @FAT-9 @FAT-13 @DIA-10 @LIM-1 @edge
  Scenario: On the closing day, the statement that closes today is already "closed" for payment and reserve
    Given today is 2026-04-03
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 50.00 since 2026-01-01
    And the daily budget source is card "Purple"
    And the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-20
    Then the 2026-04 statement of card "Purple" is "closed"
    And the current open statement of card "Purple" is the 2026-05 one
    And the available limit of card "Purple" is R$ 4,700.00
    And the daily reserve on 2026-04-03 goes into the derived outflow of the 2026-05 statement
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 300.00 on 2026-04-10
    And there is no question "Did you pay?" for the 2026-04 statement of card "Purple"
    When I pay R$ 300.00 to card "Purple" from account "Nubank" on 2026-04-03 without choosing the statement
    Then the payment is linked to the 2026-04 statement
    And the 2026-04 statement of card "Purple" is "paid"

  @integration @GER-12 @LAN-7 @PRJ-3 @PRJ-7 @edge
  Scenario Outline: The last day of the horizon is inclusive and the next day does not exist
    Given today is <today>
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on <today>
    And the daily amount is R$ 0.00 since <today>
    And the projection horizon is <months> months
    When I add the expense "Limit" of R$ 1,100.00 to account "Nubank" on <end> as planned
    Then the consolidated projected balance on <end> is -R$ 100.00
    And the lowest future balance is -R$ 100.00 on <end>
    And the first negative day is <end>
    And there is no projected balance on <after>
    When I add the expense "Outside" of R$ 10.00 to account "Nubank" on <after> as planned
    Then the operation is blocked with the message "Date after the horizon end (<end>)"

    Examples:
      | today      | months | end        | after      |
      | 2026-01-31 | 1      | 2026-02-28 | 2026-03-01 |
      | 2027-08-31 | 6      | 2028-02-29 | 2028-03-01 |
      | 2028-02-29 | 12     | 2029-02-28 | 2029-03-01 |
      | 2026-03-15 | 24     | 2028-03-15 | 2028-03-16 |

  @integration @GER-12 @PRJ-3 @FAT-6 @PRJ-7 @edge
  Scenario: A statement due on the last day of the horizon is included; one due later is included when the horizon moves
    Given today is 2026-03-05
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the daily amount is R$ 0.00 since 2026-01-01
    And the projection horizon is 1 month
    And the purchase "Dinner" of R$ 200.00 on card "Black" on 2026-03-04
    And the purchase "Book" of R$ 100.00 on card "Purple" on 2026-03-04
    Then the horizon end is 2026-04-05
    And the derived outflow of the 2026-04 statement of card "Black" is R$ 200.00 on 2026-04-05
    And the 2026-04 statement of card "Purple" is left out of the projection
    And the lowest future balance is R$ 800.00 on 2026-04-05
    When the day turns to 2026-03-10
    Then the horizon end is 2026-04-10
    And the consolidated projected balance on 2026-04-10 is R$ 700.00
    And the lowest future balance is R$ 700.00 on 2026-04-10

  @integration @GER-12 @REC-4 @GER-11 @edge
  Scenario Outline: At the end of January the horizon end stays put and jumps on February 1st
    Given today is 2026-01-27
    And the projection horizon is 1 month
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the recurring expense "Internet" of R$ 100.00 in account "Nubank", monthly, starting 2026-02-01, with no end
    When the day turns to <today>
    Then the horizon end is <end>
    And the 2026-03-01 occurrence of series "Internet" <exists>

    Examples:
      | today      | end        | exists             |
      | 2026-01-28 | 2026-02-28 | does not exist yet |
      | 2026-01-29 | 2026-02-28 | does not exist yet |
      | 2026-01-31 | 2026-02-28 | does not exist yet |
      | 2026-02-01 | 2026-03-01 | was generated      |
