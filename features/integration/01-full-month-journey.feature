Feature: March 2026 journey, from setup to the end of the month
  A user starts using the app on 2026-03-01 with a card already in use,
  lives through the month, and every action has to match balance, projection, statement, limit,
  thermometer and indicators at the same time.

  Background:
    Given today is 2026-03-01
    And the user's time zone is "America/Sao_Paulo"
    And the projection horizon is 2 months
    And the tag "groceries" that marks daily spending
    And the tag "eating out" that marks daily spending
    And the tags "home", "apps", "health" and "salary", without the daily spending flag
    And the account "Nubank" of kind "checking" with opening balance R$ 1,200.00 on 2026-03-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-03-01
    And the account "Reserve" of kind "reserve" with opening balance R$ 5,000.00 on 2026-03-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-03-01
    And I entered the current statement balance of card "Purple" as R$ 800.00
    And I entered the ongoing installment purchase "Phone" on card "Purple" bought on 2025-11-01, with a total of R$ 2,400.00 in 12 installments, currently at installment 5
    And the daily amount is R$ 60.00 since 2026-03-01
    And the recurring income "Salary" of R$ 4,500.00 in account "Nubank", monthly, starting 2026-03-05, with no end, with the tag "salary"
    And the recurring expense "Rent" of R$ 1,800.00 in account "Nubank", monthly, starting 2026-03-08, with no end, with the tag "home"
    And the recurring expense "Streaming" of R$ 39.90 on card "Purple", monthly, starting 2026-03-12, with no end, with the tag "apps"
    And the expense "Bakery" of R$ 18.00 in account "Wallet" on 2026-03-01 with the tag "groceries"

  @integration @CAR-9 @CAR-8 @CON-6 @CON-10 @DIA-5 @DIA-10 @LIM-1 @LIM-3 @FAT-4 @FAT-6 @PRJ-2 @PRJ-3 @PRJ-7 @REC-4 @TER-2 @INV-4
  Scenario: State right after setup
    Then "Nubank" is the default account and the daily budget source
    And the account "Reserve" has purpose "saving"
    And the expense "Bakery" is daily spending
    And the installments of the purchase "Phone" are:
      | k  | amount    | statement | accrual | status    |
      | 1  | R$ 200.00 | —         | 2025-11 | pre-app   |
      | 4  | R$ 200.00 | —         | 2026-02 | pre-app   |
      | 5  | R$ 200.00 | 2026-03   | 2026-03 | confirmed |
      | 6  | R$ 200.00 | 2026-04   | 2026-04 | confirmed |
      | 12 | R$ 200.00 | 2026-10   | 2026-10 | confirmed |
    And the sum of the installments of the purchase "Phone", counting the pre-app ones, is R$ 2,400.00
    And the purchase "Pre-app balance" of R$ 800.00 has date 2026-03-01 and is in the 2026-03 statement
    And installments 1 to 4 and the "Pre-app balance" do not count in any indicator nor in the tag report
    And the 2026-03 statement of card "Purple" closes on 2026-03-03 and is due on 2026-03-10
    And the 2026-03 statement of card "Purple" is "open" with total R$ 1,000.00 and outstanding R$ 1,000.00
    And the 2026-04 statement of card "Purple" has total R$ 200.00 and shows "+ R$ 39.90 planned"
    And the 2026-05 statement of card "Purple" has total R$ 200.00 and shows "+ R$ 39.90 planned"
    And the available limit of card "Purple" is R$ 2,600.00
    And the available limit of card "Purple" after planned entries is R$ 2,520.20
    And the daily reserve on 2026-03-01 is R$ 42.00
    And the consolidated actual balance is R$ 1,382.00
    And the projected balance of account "Nubank" on 2026-03-01 is R$ 1,158.00
    And the projected balance of account "Wallet" on 2026-03-01 is R$ 182.00
    And the derived outflow of the 2026-03 statement of card "Purple" is R$ 1,000.00 on 2026-03-10
    And the derived outflow of the 2026-04 statement of card "Purple" is R$ 239.90 on 2026-04-10
    And the 2026-05 statement of card "Purple" is left out of the projection, because it is due after 2026-05-01
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-01 | R$ 1,340.00 | light green |
      | 2026-03-04 | R$ 1,160.00 | light green |
      | 2026-03-05 | R$ 5,600.00 | dark green  |
      | 2026-03-08 | R$ 3,620.00 | dark green  |
      | 2026-03-10 | R$ 2,500.00 | dark green  |
      | 2026-03-31 | R$ 1,240.00 | light green |
      | 2026-04-04 | R$ 1,000.00 | light green |
      | 2026-04-05 | R$ 5,440.00 | dark green  |
      | 2026-04-08 | R$ 3,460.00 | dark green  |
      | 2026-04-10 | R$ 3,100.10 | dark green  |
      | 2026-05-01 | R$ 1,840.10 | light green |
    And there is no projected balance on 2026-05-02
    And the lowest future balance is R$ 1,000.00 on 2026-04-04
    And there is no negative day

  @integration @DIA-5 @DIA-6 @DIA-8 @STA-5 @STA-6 @FAT-1 @FAT-5 @FAT-7 @FAT-9 @REC-4 @REC-9 @LIM-1 @TRF-4 @TRF-7 @PRJ-2 @PRJ-3 @PRJ-7 @TER-2 @IND-1 @IND-2 @IND-3 @IND-6 @IND-7 @IND-9 @INV-5
  Scenario: The month day by day
    # 03-02: a daily spending card purchase takes the reserve out of today's cash and puts it on the statement
    When the day turns to 2026-03-02
    Then the consolidated projected balance on 2026-03-02 is R$ 1,322.00
    When I add the purchase "Groceries" of R$ 150.00 to card "Purple" on 2026-03-02 with the tag "groceries"
    Then the purchase "Groceries" is daily spending and is "confirmed"
    And the purchase "Groceries" is in the 2026-03 statement of card "Purple"
    And the daily reserve on 2026-03-02 is R$ 0.00
    And the 2026-03 statement of card "Purple" has total R$ 1,150.00 and outstanding R$ 1,150.00
    And the available limit of card "Purple" is R$ 2,450.00
    And the consolidated actual balance is R$ 1,382.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-02 | R$ 1,382.00 | light green |
      | 2026-03-10 | R$ 2,452.00 | dark green  |
      | 2026-04-04 | R$ 952.00   | yellow      |
      | 2026-05-02 | R$ 1,732.10 | light green |
    And the lowest future balance is R$ 952.00 on 2026-04-04

    # 03-03: the statement closes; a purchase on the closing day goes to the next one
    When the day turns to 2026-03-03
    Then the 2026-03 statement of card "Purple" is "closed" with total R$ 1,150.00 and outstanding R$ 1,150.00
    And the current open statement of card "Purple" is the 2026-04 one
    When I add the purchase "Pharmacy" of R$ 45.00 to card "Purple" on 2026-03-03 with the tag "health"
    Then the purchase "Pharmacy" is not daily spending
    And the purchase "Pharmacy" is in the 2026-04 statement of card "Purple"
    And the 2026-04 statement of card "Purple" has total R$ 245.00 and shows "+ R$ 39.90 planned"
    And the available limit of card "Purple" is R$ 2,405.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-03 | R$ 1,322.00 | light green |
      | 2026-04-04 | R$ 952.00   | yellow      |
      | 2026-04-10 | R$ 3,007.10 | dark green  |
      | 2026-05-03 | R$ 1,627.10 | light green |

    # 03-05: confirming the salary does not change the projection, only the actual balance
    When the day turns to 2026-03-05
    Then the 2026-03-05 occurrence of series "Salary" is "planned"
    And the consolidated projected balance on 2026-03-05 is R$ 5,822.00
    When I confirm the 2026-03-05 occurrence of series "Salary" with amount R$ 4,500.00 on 2026-03-05
    Then the actual balance of account "Nubank" is R$ 5,700.00
    And the consolidated projected balance on 2026-03-05 is R$ 5,822.00
    And the series "Salary" has one planned occurrence on 2026-05-05
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-08 | R$ 3,842.00 | dark green  |
      | 2026-03-10 | R$ 2,572.00 | dark green  |
      | 2026-04-04 | R$ 1,072.00 | light green |
      | 2026-05-05 | R$ 6,127.10 | dark green  |
    And the lowest future balance is R$ 1,072.00 on 2026-04-04

    # 03-08: rent
    When the day turns to 2026-03-08
    And I confirm the 2026-03-08 occurrence of series "Rent" with amount R$ 1,800.00 on 2026-03-08
    Then the actual balance of account "Nubank" is R$ 3,900.00
    And the consolidated actual balance is R$ 4,082.00
    And the series "Rent" has one planned occurrence on 2026-05-08
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-08 | R$ 4,022.00 |
      | 2026-03-10 | R$ 2,752.00 |
      | 2026-04-04 | R$ 1,252.00 |
      | 2026-05-08 | R$ 4,327.10 |

    # 03-10: the statement is due today and gets paid; a payment is not an Outflow
    When the day turns to 2026-03-10
    Then the 2026-03 statement of card "Purple" is "closed"
    And the consolidated projected balance on 2026-03-10 is R$ 2,872.00
    And the realized Outflows for 2026-03 are R$ 2,045.00
    When I pay R$ 1,150.00 of the 2026-03 statement of card "Purple" from account "Nubank" on 2026-03-10
    Then the 2026-03 statement of card "Purple" is "paid" with outstanding R$ 0.00
    And the actual balance of account "Nubank" is R$ 2,750.00
    And the consolidated projected balance on 2026-03-10 is R$ 2,872.00
    And the available limit of card "Purple" is R$ 3,555.00
    And the realized Outflows for 2026-03 are R$ 2,045.00
    And the derived outflow of the 2026-05 statement of card "Purple" is R$ 239.90 on 2026-05-10
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-04-04 | R$ 1,372.00 |
      | 2026-04-10 | R$ 3,427.10 |
      | 2026-05-10 | R$ 4,087.20 |
    When the day turns to 2026-03-11
    Then there is no question "Did you pay?" for the 2026-03 statement of card "Purple"
    And the consolidated projected balance on 2026-03-11 is R$ 2,872.00

    # 03-12: the subscription confirms itself; daily spending in the account uses part of the reserve
    When the day turns to 2026-03-12
    Then the 2026-03-12 occurrence of series "Streaming" is "confirmed"
    And I see the warning "The purchase 'Streaming' was confirmed; delete it if it didn't happen"
    And the available limit of card "Purple" is R$ 3,515.10
    And the 2026-04 statement of card "Purple" has total R$ 284.90 and outstanding R$ 284.90, with no planned entries
    When I add the expense "Lunch" of R$ 35.00 to account "Nubank" on 2026-03-12 with the tag "eating out"
    Then the expense "Lunch" is daily spending
    And the daily reserve on 2026-03-12 is R$ 25.00
    And the actual balance of account "Nubank" is R$ 2,715.00
    And the consolidated projected balance is:
      | date       | balance     |
      | 2026-03-12 | R$ 2,872.00 |
      | 2026-04-04 | R$ 1,492.00 |
      | 2026-04-10 | R$ 3,547.10 |
      | 2026-05-12 | R$ 4,087.20 |

    # 03-15: saving into Reserve leaves the consolidated balance and goes into Saved
    When the day turns to 2026-03-15
    And I add the transfer "Save" of R$ 1,000.00 from account "Nubank" to account "Reserve" on 2026-03-15 as confirmed
    Then the actual balance of account "Nubank" is R$ 1,715.00
    And the actual balance of account "Reserve" is R$ 6,000.00
    And the consolidated actual balance is R$ 1,897.00
    And the projected balance of account "Reserve" on 2026-05-15 is R$ 6,000.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-15 | R$ 1,837.00 | light green |
      | 2026-03-31 | R$ 877.00   | yellow      |
      | 2026-04-04 | R$ 637.00   | yellow      |
      | 2026-04-05 | R$ 5,077.00 | dark green  |
      | 2026-04-10 | R$ 2,692.10 | dark green  |
      | 2026-05-15 | R$ 3,052.20 | dark green  |
    And the lowest future balance is R$ 637.00 on 2026-04-04
    And there is no negative day
    And the realized indicators for 2026-03 are:
      | indicator      | amount      |
      | Inflows        | R$ 4,500.00 |
      | Outflows       | R$ 2,084.90 |
      | Daily spending | R$ 203.00   |
      | Total outflows | R$ 2,287.90 |
      | Performance    | R$ 2,212.10 |
      | Saved          | R$ 1,000.00 |
      | savings rate   | 22.2%       |
      | Daily average  | R$ 13.53    |

    # 03-20: another daily spending card purchase
    When the day turns to 2026-03-20
    And I add the purchase "Market" of R$ 80.00 to card "Purple" on 2026-03-20 with the tag "groceries"
    Then the daily reserve on 2026-03-20 is R$ 0.00
    And the 2026-04 statement of card "Purple" has total R$ 364.90
    And the available limit of card "Purple" is R$ 3,435.10
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-20 | R$ 1,897.00 | light green |
      | 2026-03-31 | R$ 1,237.00 | light green |
      | 2026-04-04 | R$ 997.00   | yellow      |
      | 2026-04-10 | R$ 2,972.10 | dark green  |
      | 2026-05-20 | R$ 3,032.20 | dark green  |
    And the lowest future balance is R$ 997.00 on 2026-04-04

    # 03-31: the daily budget surpluses from 03-21 to 03-30 were released day by day
    When the day turns to 2026-03-31
    Then the consolidated actual balance is R$ 1,897.00
    And the consolidated projected balance is:
      | date       | balance     | color       |
      | 2026-03-31 | R$ 1,837.00 | light green |
      | 2026-04-04 | R$ 1,597.00 | light green |
      | 2026-04-05 | R$ 6,037.00 | dark green  |
      | 2026-04-10 | R$ 3,572.10 | dark green  |
      | 2026-05-10 | R$ 4,232.20 | dark green  |
      | 2026-05-31 | R$ 2,972.20 | dark green  |
    And the lowest future balance is R$ 1,597.00 on 2026-04-04
    And the total debt of card "Purple" is R$ 1,564.90
    And the sum of the outstanding amounts of the statements of card "Purple" is R$ 1,564.90

  @integration @IND-1 @IND-2 @IND-3 @IND-4 @IND-5 @IND-6 @IND-7 @IND-8 @IND-9 @IND-10 @IND-11 @TAG-9 @DIA-9 @INV-8 @CAR-9
  Scenario: March close: indicators, tag report and cost of living
    Given the entries of the March journey: "Groceries", "Pharmacy", "Salary" and "Rent" confirmed, 2026-03 statement paid, "Streaming", "Lunch", "Save" and "Market"
    And today is 2026-03-31
    Then the realized indicators for 2026-03 are:
      | indicator      | amount      |
      | Inflows        | R$ 4,500.00 |
      | Outflows       | R$ 2,084.90 |
      | Daily spending | R$ 283.00   |
      | Total outflows | R$ 2,367.90 |
      | Performance    | R$ 2,132.10 |
      | Saved          | R$ 1,000.00 |
      | savings rate   | 22.2%       |
      | Daily average  | R$ 9.13     |
    And the forecast indicators for 2026-03 are the same as the realized ones
    And the realized Outflows list for 2026-03 shows "Rent" with R$ 1,800.00, "Phone (5/12)" with R$ 200.00, "Pharmacy" with R$ 45.00 and "Streaming" with R$ 39.90
    And the realized Outflows list for 2026-03 does not show "Pre-app balance" nor the statement payment
    And the realized Daily spending list for 2026-03 shows "Bakery" with R$ 18.00, "Groceries" with R$ 150.00, "Lunch" with R$ 35.00 and "Market" with R$ 80.00
    And the realized tag report for 2026-03 shows:
      | tag        | expenses    | income      |
      | home       | R$ 1,800.00 | R$ 0.00     |
      | groceries  | R$ 248.00   | R$ 0.00     |
      | Untagged   | R$ 200.00   | R$ 0.00     |
      | health     | R$ 45.00    | R$ 0.00     |
      | apps       | R$ 39.90    | R$ 0.00     |
      | eating out | R$ 35.00    | R$ 0.00     |
      | salary     | R$ 0.00     | R$ 4,500.00 |
    And the sum of the report expenses is R$ 2,367.90, equal to Total outflows
    And the sum of the report income is R$ 4,500.00, equal to Inflows
    And the daily budget from 2026-03-01 to 2026-03-31 has budgeted R$ 1,860.00, spent R$ 283.00 and surplus R$ 1,577.00
    And the forecast indicators for 2026-04 are:
      | indicator      | amount      |
      | Inflows        | R$ 4,500.00 |
      | Outflows       | R$ 2,039.90 |
      | Daily spending | R$ 0.00     |
      | Performance    | R$ 2,460.10 |
    When the day turns to 2026-04-01
    Then the cost of living is R$ 2,367.90, computed only from 2026-03

  @integration @CAR-9 @CAR-8 @FAT-5 @FAT-6 @FAT-9 @STA-4 @PRJ-2 @LIM-1 @INV-7
  Scenario Outline: Starting with a closed unpaid statement
    Given today is <today>
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-03-01
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date <today>
    And I enter the closed unpaid statement balance of card "Purple" as R$ 700.00
    Then the purchase "Pre-app balance" of R$ 700.00 has date 2026-03-02 and is in the 2026-03 statement of card "Purple"
    And the 2026-03 statement of card "Purple" is "<status>" with outstanding R$ 700.00
    And the available limit of card "Purple" is R$ 4,300.00
    And the "Pre-app balance" is valid under INV-7 even with a date before the start date, through the exception in CAR-9
    And <question> "Did you pay?" for the 2026-03 statement of card "Purple"
    And the projected balance of account "Nubank" on <today> is <projected today>

    Examples:
      | today      | status  | question             | projected today |
      | 2026-03-05 | closed  | there is no question | R$ 2,000.00     |
      | 2026-03-10 | closed  | there is no question | R$ 1,300.00     |
      | 2026-03-15 | overdue | I see the question   | R$ 1,300.00     |
