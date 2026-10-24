# Realistic data set checked by hand. Today is 2026-03-15, so February is a past month (realized only) and all entries are confirmed with accrual ≤ today.
#
#
#
# ### Hand check of February (done twice)
#
# - **Inflows** = Salary 6,000.00 + Freelance 1,500.00 = **7,500.00**. Left out: Yield (Reserve, IND-12), adjustment (AJU-4), transfers and refunds.
# - **Outflows** = Rent 2,200.00 + Electricity 180.00 + Netflix 55.90 + Phone 2/3 600.00 = 3,035.90; − Annual Fee (unlinked refund) 30.00 = **3,005.90**. Left out: Pharmacy (accrual Jan), Reserve Fee (IND-12) and statement payment (FAT-7).
# - **Daily spending** = Market 85.40 + Bakery 23.60 + Supermarket 412.30 + Uber 47.90 = 569.20; − Supermarket refund 52.30 = **516.90**.
# - **Total outflows** = 3,005.90 + 516.90 = **3,522.80**. **Performance** = 7,500.00 − 3,522.80 = **3,977.20**.
# - **Saved** = Save 1,000.00 − Withdrawal 300.00 = **700.00**. Cash Withdrawal does not count (spending → spending). **%** = 700 ÷ 7,500 = 9.333…% → **9.3%**. **Daily average** = 516.90 ÷ 28 = 18.4607… → **18.46**.
# - **Report**: home 2,200 + 180 = 2,380.00; groceries 85.40 + 412.30 − 52.30 (refund, tags prefilled from the purchase) = 445.40; transport 47.90; apps 55.90; Untagged 23.60 + 600.00 − 30.00 = 593.60. Σ = 2,380.00 → 2,825.40 → 2,873.30 → 2,929.20 → **3,522.80** = Total outflows. Income: 1,500 + 6,000 = 7,500.00 = Inflows. **INV-8 ok.**
# - **With an account refund of 20.00 on Electricity**: Outflows 2,985.90; Total outflows 3,502.80; Performance 3,997.20; home 2,360.00; Σ expenses 3,502.80. INV-8 ok.
# - **Wallet → saving**: Market and Bakery leave Daily spending (516.90 − 109.00 = 407.90); Cash Withdrawal becomes Saved (+150 → 850.00); Total outflows 3,413.80; Performance 4,086.20; % 850 ÷ 7,500 = 11.33% → 11.3%; average 407.90 ÷ 28 = 14.5678… → 14.57. Report: groceries 412.30 − 52.30 = 360.00; Untagged 600.00 − 30.00 = 570.00; Σ 3,413.80. Wallet can become saving because it is not the default account, nor the daily budget source, nor a payment account.
# - **Reserve → spending**: Inflows + 32.10 = 7,532.10; Outflows + 5.00 = 3,010.90; Total outflows 3,527.80; Performance 4,004.30; Save and Withdrawal become spending ↔ spending → Saved 0.00.
# - **Statements**: Phone (Black, 2026-01-25): installment 1 in the statement that closes on 2026-01-28 (label 2026-02), installment 2 in the one that closes on 2026-02-28 (2026-03), installment 3 in 2026-04. Pharmacy (Purple, 2026-01-20) falls in the cycle [2026-01-03, 2026-02-03), 2026-02 statement due on 2026-02-10, paid that day.
Feature: Full February: indicators, tag report and INV-8

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 200.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And "Nubank" is the default account
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the tag "groceries" that marks daily spending
    And the tags "home, transport, apps, work, health, goal, leisure"
    # January (outside February)
    And the purchase "Pharmacy" of R$ 800.00 on card "Purple" on 2026-01-20 with the tag "health"
    And the purchase "Phone" of R$ 1,800.00 on card "Black" on 2026-01-25 in 3 installments
    # February
    And the transfer "Cash Withdrawal" of R$ 150.00 from account "Nubank" to account "Wallet" on 2026-02-03, confirmed
    And the income "Salary" of R$ 6,000.00 in account "Nubank" on 2026-02-05, confirmed
    And the transfer "Save" of R$ 1,000.00 from account "Nubank" to account "Reserve" on 2026-02-06, confirmed, with the tag "goal"
    And the expense "Market" of R$ 85.40 in account "Wallet" on 2026-02-07, confirmed, with the tag "groceries"
    And the purchase "Supermarket" of R$ 412.30 on card "Purple" on 2026-02-08 with the tag "groceries"
    And the expense "Rent" of R$ 2,200.00 in account "Nubank" on 2026-02-10, confirmed, with the tag "home"
    And the payment of R$ 800.00 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed
    And the expense "Electricity" of R$ 180.00 in account "Nubank" on 2026-02-12, confirmed, with the tag "home"
    And the expense "Bakery" of R$ 23.60 in account "Wallet" on 2026-02-14, confirmed, as daily spending
    And the refund "Supermarket" of R$ 52.30 on card "Purple" on 2026-02-15 linked to the purchase "Supermarket"
    And the purchase "Uber" of R$ 47.90 on card "Black" on 2026-02-18, as daily spending, with the tag "transport"
    And the income "Freelance" of R$ 1,500.00 in account "Nubank" on 2026-02-20, confirmed, with the tag "work"
    And the purchase "Netflix" of R$ 55.90 on card "Purple" on 2026-02-20 with the tag "apps"
    And the transfer "Withdrawal" of R$ 300.00 from account "Reserve" to account "Nubank" on 2026-02-25, confirmed
    And the refund "Annual Fee" of R$ 30.00 on card "Black" on 2026-02-26, unlinked
    And the inflow adjustment of R$ 12.00 in account "Nubank" on 2026-02-27
    And the income "Yield" of R$ 32.10 in account "Reserve" on 2026-02-28, confirmed
    And the expense "Reserve Fee" of R$ 5.00 in account "Reserve" on 2026-02-28, confirmed

  @TAG-4 @EST-1 @IND-2 @PAR-1 @AJU-4
  Scenario: Check of the data set's flags, tags and accrual
    Then the expense "Market" is daily spending
    And the purchase "Supermarket" is daily spending
    And the purchase "Uber" is daily spending
    And the expense "Rent" is not daily spending
    And the refund "Supermarket" has the tags "groceries"
    And the 2026-02-27 adjustment has no tags
    And installment 2 of the purchase "Phone" is worth R$ 600.00, has accrual date 2026-02-25 and is in the 2026-03 statement of card "Black"
    And the purchase "Pharmacy" counts in the indicators for 2026-01

  @IND-1 @IND-2 @IND-3 @IND-4 @IND-5 @IND-6 @IND-7 @IND-9 @IND-12 @EST-3 @AJU-4 @TRF-3 @TRF-4 @FAT-7
  Scenario: Realized indicators for February
    Then the realized indicators for 2026-02 are:
      | indicator      | amount      |
      | Inflows        | R$ 7,500.00 |
      | Outflows       | R$ 3,005.90 |
      | Daily spending | R$ 516.90   |
      | Total outflows | R$ 3,522.80 |
      | Performance    | R$ 3,977.20 |
      | Saved          | R$ 700.00   |
      | savings rate   | 9.3%        |
      | Daily average  | R$ 18.46    |
    And the forecast version for 2026-02 is not shown

  @TAG-9 @TAG-10 @EST-3 @AJU-4 @IND-12 @FAT-7
  Scenario: Realized tag report for February
    Then the realized tag report for 2026-02 shows:
      | tag       | expenses    | income      |
      | home      | R$ 2,380.00 | R$ 0.00     |
      | groceries | R$ 445.40   | R$ 0.00     |
      | transport | R$ 47.90    | R$ 0.00     |
      | apps      | R$ 55.90    | R$ 0.00     |
      | work      | R$ 0.00     | R$ 1,500.00 |
      | Untagged  | R$ 593.60   | R$ 6,000.00 |
    And the tag "goal" does not appear in the realized tag report for 2026-02
    And the tag "leisure" does not appear in the realized tag report for 2026-02
    And the tag "health" does not appear in the realized tag report for 2026-02
    And the report does not show the multi-tag warning

  @TAG-9 @IND-10
  Scenario: List of entries for a tag and for "Untagged"
    When I open the tag "groceries" in the realized report for 2026-02
    Then I see the entries:
      | entry                | amount    |
      | Market               | R$ 85.40  |
      | Supermarket          | R$ 412.30 |
      | Supermarket (refund) | -R$ 52.30 |
    When I open "Untagged" in the realized report for 2026-02
    Then I see the entries:
      | entry               | amount      |
      | Bakery              | R$ 23.60    |
      | Phone (2/3)         | R$ 600.00   |
      | Annual Fee (refund) | -R$ 30.00   |
      | Salary              | R$ 6,000.00 |
    And I do not see "Cash Withdrawal, Save, Withdrawal, statement payment, adjustment, Yield, Reserve Fee"

  @INV-8 @IND-5 @TAG-9
  Scenario: INV-8 checked by hand in February
    Then the realized Performance for 2026-02 is R$ 7,500.00 − R$ 3,005.90 − R$ 516.90 = R$ 3,977.20
    And the sum of the expenses column of the realized tag report for 2026-02 is R$ 2,380.00 + R$ 445.40 + R$ 47.90 + R$ 55.90 + R$ 593.60 = R$ 3,522.80
    And that sum equals the realized Total outflows for 2026-02
    And the sum of the income column of the realized tag report for 2026-02 is R$ 1,500.00 + R$ 6,000.00 = R$ 7,500.00, equal to the realized Inflows

  @EST-7 @INV-8 @TAG-9
  Scenario: An account refund keeps INV-8
    Given the account refund "Electricity" of R$ 20.00 in account "Nubank" on 2026-02-16 linked to the expense "Electricity"
    Then the account refund "Electricity" has the tags "home"
    And the realized indicators for 2026-02 are:
      | indicator      | amount      |
      | Inflows        | R$ 7,500.00 |
      | Outflows       | R$ 2,985.90 |
      | Daily spending | R$ 516.90   |
      | Total outflows | R$ 3,502.80 |
      | Performance    | R$ 3,997.20 |
    And the realized tag report for 2026-02 shows the tag "home" with expenses R$ 2,360.00
    And the sum of the expenses column of the realized tag report for 2026-02 is R$ 3,502.80, equal to Total outflows

  @TAG-9
  Scenario: An entry with several tags counts in full in each one and the screen warns
    Given the purchase "Movies and Uber" of R$ 98.00 on card "Black" on 2026-02-21 with the tags "leisure, transport"
    Then the realized Total outflows for 2026-02 is R$ 3,620.80
    And the realized tag report for 2026-02 shows:
      | tag       | expenses    | income      |
      | home      | R$ 2,380.00 | R$ 0.00     |
      | groceries | R$ 445.40   | R$ 0.00     |
      | transport | R$ 145.90   | R$ 0.00     |
      | apps      | R$ 55.90    | R$ 0.00     |
      | leisure   | R$ 98.00    | R$ 0.00     |
      | work      | R$ 0.00     | R$ 1,500.00 |
      | Untagged  | R$ 593.60   | R$ 6,000.00 |
    And the sum of the expenses column is R$ 3,718.80, greater than Total outflows by R$ 98.00
    And I see the warning "Entries with more than one tag appear under each one, so the sum by tag exceeds the month's total"

  @IND-10 @IND-2
  Scenario: Outflows opens the list of entries that make up the number
    When I open the realized Outflows for 2026-02
    Then I see the entries:
      | entry               | amount      |
      | Rent                | R$ 2,200.00 |
      | Electricity         | R$ 180.00   |
      | Netflix             | R$ 55.90    |
      | Phone (2/3)         | R$ 600.00   |
      | Annual Fee (refund) | -R$ 30.00   |
    And the sum of the list is R$ 3,005.90

  @IND-10 @IND-3
  Scenario: Daily spending opens the list of entries that make up the number
    When I open the realized Daily spending for 2026-02
    Then I see the entries:
      | entry                | amount    |
      | Market               | R$ 85.40  |
      | Supermarket          | R$ 412.30 |
      | Bakery               | R$ 23.60  |
      | Supermarket (refund) | -R$ 52.30 |
      | Uber                 | R$ 47.90  |
    And the sum of the list is R$ 516.90

  @IND-10 @IND-1 @IND-6
  Scenario: Inflows and Saved open their lists
    When I open the realized Inflows for 2026-02
    Then I see exactly "Salary R$ 6,000.00, Freelance R$ 1,500.00"
    When I open the realized Saved for 2026-02
    Then I see exactly "Save R$ 1,000.00, Withdrawal -R$ 300.00"
    And I do not see "Cash Withdrawal"

  @IND-10 @IND-7 @IND-9
  Scenario: A derived indicator opens the indicators it is made of
    When I open the realized savings rate for 2026-02
    Then I see the Saved (R$ 700.00) and the Inflows (R$ 7,500.00), each opening its own list
    When I open the realized Daily average for 2026-02
    Then I see the Daily spending (R$ 516.90) and the divisor 28

  @CON-12 @CON-6 @IND-6 @IND-12 @INV-8
  Scenario: Wallet becomes saving and the February history is recomputed
    When I change the purpose of account "Wallet" to "saving"
    Then I see the warning "Changing the purpose recalculates the indicators for this account's entire history"
    When I confirm the warning
    Then the expense "Market" is still flagged as daily spending, but the flag is ignored
    And the realized indicators for 2026-02 are:
      | indicator      | amount      |
      | Inflows        | R$ 7,500.00 |
      | Outflows       | R$ 3,005.90 |
      | Daily spending | R$ 407.90   |
      | Total outflows | R$ 3,413.80 |
      | Performance    | R$ 4,086.20 |
      | Saved          | R$ 850.00   |
      | savings rate   | 11.3%       |
      | Daily average  | R$ 14.57    |
    And the realized tag report for 2026-02 shows:
      | tag       | expenses    | income      |
      | home      | R$ 2,380.00 | R$ 0.00     |
      | groceries | R$ 360.00   | R$ 0.00     |
      | transport | R$ 47.90    | R$ 0.00     |
      | apps      | R$ 55.90    | R$ 0.00     |
      | work      | R$ 0.00     | R$ 1,500.00 |
      | Untagged  | R$ 570.00   | R$ 6,000.00 |
    And the sum of the expenses column is R$ 3,413.80, equal to Total outflows

  @CON-12 @CON-6 @IND-1 @IND-2 @IND-6
  Scenario: Reserve becomes spending and yield, fee and transfers change roles
    When I change the purpose of account "Reserve" to "spending" and confirm the warning
    Then the realized indicators for 2026-02 are:
      | indicator      | amount      |
      | Inflows        | R$ 7,532.10 |
      | Outflows       | R$ 3,010.90 |
      | Daily spending | R$ 516.90   |
      | Total outflows | R$ 3,527.80 |
      | Performance    | R$ 4,004.30 |
      | Saved          | R$ 0.00     |
      | savings rate   | 0.0%        |

  @CON-12
  Scenario: Switching the purpose back restores the numbers and the daily spending flags
    When I change the purpose of account "Wallet" to "saving" and confirm the warning
    And I change the purpose of account "Wallet" to "spending" and confirm the warning
    Then the realized Daily spending for 2026-02 is R$ 516.90
    And the realized Saved for 2026-02 is R$ 700.00
    And the expense "Market" is daily spending

  @CON-12 @error
  Scenario: The default account cannot become saving
    When I change the purpose of account "Nubank" to "saving"
    Then the operation is blocked with the message "The default account must be a spending account. Choose another one first"
    And the account "Nubank" has purpose "spending"
    And the realized Daily spending for 2026-02 is R$ 516.90
