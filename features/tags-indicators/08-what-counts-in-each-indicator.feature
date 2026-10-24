Feature: What counts in each indicator

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 3,000.00 on 2026-01-01
    And the account "Wallet" of kind "cash" with opening balance R$ 2,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 5,000.00 on 2026-01-01
    And the account "Savings" of kind "savings" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01
    And the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5, payment account "Nubank" and start date 2026-01-01
    And the purchase "Base" of R$ 1,000.00 on card "Purple" on 2026-01-20

  # "the adjustment ... on 2026-02-10" = adjustment created when today was 2026-02-10 (AJU-1 always uses today's date).
  @IND-1 @IND-2 @IND-3 @IND-5 @IND-6 @IND-12 @AJU-4 @TRF-3 @TRF-4 @EST-3 @FAT-7 @INV-8
  Scenario Outline: A single R$ 1,000.00 entry in February and its effect on each indicator
    Given <entry>
    Then the realized indicators for 2026-02 are:
      | Inflows   | Outflows   | Daily spending   | Performance   | Saved   |
      | <inflows> | <outflows> | <daily spending> | <performance> | <saved> |

    Examples:
      | entry                                                                                                               | inflows     | outflows     | daily spending | performance  | saved        |
      | the income "Salary" of R$ 1,000.00 in account "Nubank" on 2026-02-10, confirmed                                     | R$ 1,000.00 | R$ 0.00      | R$ 0.00        | R$ 1,000.00  | R$ 0.00      |
      | the income "Yield" of R$ 1,000.00 in account "Reserve" on 2026-02-10, confirmed                                     | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the inflow adjustment of R$ 1,000.00 in account "Nubank" on 2026-02-10                                              | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the outflow adjustment of R$ 1,000.00 in account "Nubank" on 2026-02-10                                             | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the expense "Rent" of R$ 1,000.00 in account "Nubank" on 2026-02-10, confirmed                                      | R$ 0.00     | R$ 1,000.00  | R$ 0.00        | -R$ 1,000.00 | R$ 0.00      |
      | the expense "Market" of R$ 1,000.00 in account "Wallet" on 2026-02-10, confirmed, as daily spending                 | R$ 0.00     | R$ 0.00      | R$ 1,000.00    | -R$ 1,000.00 | R$ 0.00      |
      | the expense "Fee" of R$ 1,000.00 in account "Reserve" on 2026-02-10, confirmed                                      | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the purchase "Fridge" of R$ 1,000.00 on card "Black" on 2026-02-10                                                  | R$ 0.00     | R$ 1,000.00  | R$ 0.00        | -R$ 1,000.00 | R$ 0.00      |
      | the purchase "Restaurant" of R$ 1,000.00 on card "Purple" on 2026-02-10, as daily spending                          | R$ 0.00     | R$ 0.00      | R$ 1,000.00    | -R$ 1,000.00 | R$ 0.00      |
      | the refund "Cashback" of R$ 1,000.00 on card "Purple" on 2026-02-10                                                 | R$ 0.00     | -R$ 1,000.00 | R$ 0.00        | R$ 1,000.00  | R$ 0.00      |
      | the transfer "Cash Withdrawal" of R$ 1,000.00 from account "Nubank" to account "Wallet" on 2026-02-10, confirmed    | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the transfer "Save" of R$ 1,000.00 from account "Nubank" to account "Reserve" on 2026-02-10, confirmed              | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 1,000.00  |
      | the transfer "Withdrawal" of R$ 1,000.00 from account "Reserve" to account "Nubank" on 2026-02-10, confirmed        | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | -R$ 1,000.00 |
      | the transfer "Investment" of R$ 1,000.00 from account "Reserve" to account "Savings" on 2026-02-10, confirmed       | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |
      | the payment of R$ 1,000.00 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed | R$ 0.00     | R$ 0.00      | R$ 0.00        | R$ 0.00      | R$ 0.00      |

  @FAT-7 @IND-2
  Scenario: A statement payment never appears; the purchase counts in its own month
    Given the payment of R$ 1,000.00 of the 2026-02 statement of card "Purple" from account "Nubank" on 2026-02-10, confirmed
    Then the realized Outflows for 2026-01 are R$ 1,000.00
    And the realized Outflows for 2026-02 are R$ 0.00
    And the realized Outflows list for 2026-02 is empty

  @CAR-3 @error
  Scenario: A saving account cannot be the card's payment account
    When I change the default payment account of card "Black" to "Reserve"
    Then the operation is blocked with the message "The payment account must be a spending account"
    And the default payment account of card "Black" is "Nubank"

  @IND-6 @TRF-4 @FAT-7 @edge
  Scenario: A manual statement payment from a saving account counts as a withdrawal
    Given the purchase "Pharmacy" of R$ 200.00 on card "Black" on 2026-02-10
    And the payment of R$ 200.00 of the 2026-03 statement of card "Black" from account "Reserve" on 2026-03-05, confirmed
    Then the realized Outflows for 2026-02 are R$ 200.00
    And the realized Saved for 2026-03 is -R$ 200.00
    And the realized Saved list for 2026-03 shows "Black statement payment (withdrawal)" with -R$ 200.00
    And the realized Outflows for 2026-03 are R$ 0.00

  @GER-5 @CON-13 @IND-3
  Scenario: An archived account stays in past indicators
    Given the account "Pocket" of kind "cash" with opening balance R$ 0.00 on 2026-01-01
    And the transfer "Cash Withdrawal" of R$ 100.00 from account "Nubank" to account "Pocket" on 2026-02-01, confirmed
    And the expense "Market" of R$ 100.00 in account "Pocket" on 2026-02-07, confirmed, as daily spending
    When I archive the account "Pocket"
    Then the realized Daily spending for 2026-02 is R$ 100.00
    And the realized Daily spending list for 2026-02 shows "Market" with R$ 100.00

  @IND-2 @FAT-9
  Scenario: Revolving interest added as a card expense counts in Outflows
    Given the purchase "Revolving Interest" of R$ 87.45 on card "Purple" on 2026-03-11
    Then the realized Outflows for 2026-03 are R$ 87.45
