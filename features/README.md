# Features

Executable spec: Gherkin scenarios in English (no `# language:` header), one folder per area.
Every scenario is tagged with the rule ids it proves (see [../docs/business-rules.md](../docs/business-rules.md)).
`bun run features` validates the syntax and the tags.

| Folder | Area |
|---|---|
| `accounts/` | accounts and balance adjustment (§1) |
| `credit-cards/` | cards, statements and limit (§2) |
| `entries/` | entries, status, refunds and transfers (§3.1–3.3) |
| `recurrence-installments/` | recurrence and installments (§3.4–3.5) |
| `daily-budget-projection/` | daily budget, projection, simulation and thermometer (§4, §6, §7) |
| `tags-indicators/` | tags and indicators (§5, §8) |
| `integration/` | flows that cross several areas, and invariants (§11) |

## Conventions

How the scenarios are written. Every `.feature` follows this, so that steps become reusable step definitions (Cucumber/Gherkin, English dialect).

### Format

- Gherkin in English, one `.feature` file per feature, with no language header.
- Keywords: `Feature`, `Background`, `Scenario`, `Scenario Outline`, `Examples`, `Given`, `When`, `Then`, `And`, `But`.
- Every scenario has **tags with the ids of the rules** it proves: `@CON-3 @TRF-6`. Extra tags: `@edge` (boundary case), `@error` (validation/block), `@integration`.
- One behavior per scenario. Values are always concrete, never "any value".
- Tabulated cases (boundaries, end-of-month dates) use `Scenario Outline` + `Examples`.
- An ambiguity found becomes a `# PENDING DECISION: ...` comment above the scenario, with the assumed behavior.
- The clock is fixed: every scenario sets "today" explicitly (`Given today is ...`) and moves it only with `When the day turns to ...`.

### Sample data

- **Default today:** `2026-03-15` (Sunday), unless the scenario needs another date.
- Dates in ISO format `YYYY-MM-DD` (months `YYYY-MM`). Display short forms are written `MM-DD` (`due 03-05`).
- Money in the format `R$ 1,234.56`, negatives `-R$ 50.00`, zero `R$ 0.00`. Other numbers use a decimal point (`22.2%`).
- **Exception:** what the user types into the amount field stays in pt-BR input format, because that is what the field parses (LAN-4): `When I type "120+35,90" in the amount`, `the amount field shows "155,90"`. `1,234.56` is an *invalid* typed expression. Result amounts and messages follow the money format above.
- Accounts: `Nubank` (checking, spending), `Wallet` (cash, spending), `Reserve` (reserve, saving).
- Cards: `Purple` (limit R$ 5,000.00, closes day 3, due day 10, paid from `Nubank`), `Black` (limit R$ 10,000.00, closes day 28, due day 5, paid from `Nubank`).
- 2028 is a leap year; 2026 and 2027 are not.
- **"The YYYY-MM statement" is the label**, the month of the **due date** (FAT-0), never the identity. The identity is card + cycle sequence number and does not change when the closing day changes (CAR-5). On `Purple` the label matches the closing month; on `Black` the 2026-04 statement closes on 2026-03-28.
- **A card with past purchases** is created with **start date 2026-01-01** (or earlier than the oldest purchase), otherwise the purchase is blocked by CAR-8. Only CAR-9 entries ("Pre-app balance", pre-app installments) may have a date before the start date.
- Quoted text inside a message uses single quotes: `"The purchase 'Netflix' was confirmed; delete it if it didn't happen"`.

### Step vocabulary

Use the exact wording below; it becomes a step definition. `Given` describes state, `When` the user's action, `Then` the result. State steps say `in account` / `on card` with the status after a comma (`..., confirmed`); action steps use **add** for creating any entry, with `to account` / `to card`.

#### Time and time zone
- `Given today is 2026-03-15`
- `When the day turns to 2026-03-16`
- `Given the user's time zone is "America/Manaus"`
- `When I change the time zone to "America/Manaus"`
- `Then I see the confirmation prompt "Changing the time zone changes today's date. No entry date will be changed"` / `When I confirm the time zone change`
- `Then I see the warning "1 confirmed entry now has tomorrow's date in the new time zone"` (plural: `"2 confirmed entries now have tomorrow's date in the new time zone"`)
- `Given the first account was created on 2026-01-01` (start of use, DIA-3, IND-9)

#### Accounts
- `Given the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01`
- `Given the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 0.00 on 2026-01-01`
- `Given "Nubank" is the default account` / `Then "Nubank" is the default account` / `Then there is no default account`
- `When I set "Wallet" as the default account`
- `When I create the account "Itaú" of kind "checking" with opening balance R$ 500.00 on 2026-03-01`
- `When I change the opening balance of account "Nubank" to R$ 1,200.00`
- `When I change the opening date of account "Nubank" to 2026-02-01`
- `When I change the purpose of account "Wallet" to "saving"` / `When I change the purpose of account "Wallet" to "spending" and confirm the warning`
- `When I archive the account "Nubank"` / `When I delete the account "Nubank"`
- `Then the operation is blocked with the message "Resolve the pending items before archiving"` + `And I see the pending items:` (table)
- `Then the account "Wallet" is archived`
- `Then the actual balance of account "Nubank" is R$ 1,200.00`
- `Then the consolidated actual balance is R$ 1,200.00`

#### Balance adjustment
- `When I adjust the balance of account "Nubank" to R$ 950.00`
- `Given the inflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15` (or `outflow`)
- `Then there is an outflow adjustment of R$ 50.00 in account "Nubank" on 2026-03-15, confirmed`
- `When I delete the adjustment of R$ 50.00 from account "Nubank"`

#### Messages and confirmations
- `Then the operation is blocked with the message "..."`
- `Then I see the warning "..."` / `Then I do not see the warning "..."`
- `When I confirm the warning` / `When I confirm the deletion`
- `Then I see the confirmation prompt "..."` (any confirmation, not only the time zone)
- `Then I do not see the option "Undo"`
- `When I tap "Undo" after 2 seconds` (GER-5: valid up to 5 seconds)

#### Cards and statements
- `Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date 2026-01-01` (preferred form, start date **on the same line**; without a start date, today applies)
- `When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"`
- `When I change the start date of card "Purple" to 2026-03-01` / `Given I changed the start date of card "Purple" to 2026-03-01` / `Then the start date of card "Purple" is 2026-03-01`
- `When I change the closing day of card "Purple" to 20` (with `and the due day to 15`, if both change)
- `When I change the default payment account of card "Black" to "Nubank"`
- `When I archive the card "Purple"` / `Then the card "Purple" is archived`
- `When I enter the current statement balance of card "Purple" as R$ 450.00` (CAR-9 a)
- `When I enter the closed unpaid statement balance of card "Purple" as R$ 800.00` (CAR-9 b)
- `When I enter the ongoing installment purchase "Fridge" on card "Purple" bought on 2026-01-10, with a total of R$ 1,200.00 in 6 installments, currently at installment 3` (CAR-9 c)
- `Then the purchase "Sneakers" is in the 2026-04 statement of card "Purple"`
- `Then the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-10`
- `Then the current open statement of card "Purple" is the 2026-04 one`
- `Then the 2026-04 statement of card "Purple" has total R$ 300.00 and outstanding R$ 300.00`
- `Then the 2026-04 statement of card "Purple" shows "+ R$ 80.00 planned"`
- `Then the 2026-04 statement of card "Purple" is "closed"` (also `is "closed" with outstanding R$ 300.00`)
- `Then the 2026-05 statement of card "Purple" has carried-over balance R$ 3,000.00` / `has carried-over credit R$ 50.00`
- `Then the 2026-04 statement of card "Purple" has a refund linked to the purchase "TV" of R$ 200.00 on 2026-04-05`
- `Then the 2026-04 statement of card "Purple" has the linked charge "Cancellation settlement" of R$ 200.00 on 2026-04-05`
- `Given the payment of R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08, confirmed` (or `, planned`)
- `When I pay R$ 300.00 of the 2026-04 statement of card "Purple" from account "Nubank" on 2026-04-08`
- `When I delete the payment of R$ 300.00 of the 2026-04 statement of card "Purple"`
- `When I withdraw R$ 50.00 of credit from card "Purple" to account "Nubank" on 2026-03-15`
- `When I move the purchase "Hotel" to the next statement` (or `previous`) / `Given I moved the purchase "Hotel" to the next statement`
- `Then I see the question "Did you pay?" for the 2026-04 statement of card "Purple"` / `Then there is no question "Did you pay?" for the 2026-04 statement of card "Purple"`
- `When I answer "I didn't pay" for the 2026-04 statement of card "Purple"` / `Given I answered "I didn't pay" for the 2026-04 statement of card "Purple"` / `When I undo the "I didn't pay" on the 2026-04 statement of card "Purple"`
- `Then the available limit of card "Purple" is R$ 4,700.00`
- `Then the available limit of card "Purple" after planned entries is R$ 4,200.00`
- `Then the total debt of card "Purple" is R$ 300.00`
- `Then I see the warning "This purchase exceeds the available limit"` (LIM-2)

#### Entries
- `Given the expense "Groceries" of R$ 120.00 in account "Nubank" on 2026-03-15, confirmed` (also `, planned`, `with the tag "groceries"`, `, confirmed, as daily spending`)
- `Given the income "Salary" of R$ 5,000.00 in account "Nubank" on 2026-04-05, planned`
- `Given the purchase "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-10` (status comes from STA-6; also `with the tag "leisure"`)
- `Given the purchase "TV" of R$ 3,000.00 on card "Purple" on 2026-03-10 in 10 installments`
- `Given the refund "Sneakers" of R$ 300.00 on card "Purple" on 2026-03-20 linked to the purchase "Sneakers"`
- `Given the account refund "Sneakers" of R$ 400.00 in account "Nubank" on 2026-03-15 linked to the expense "Sneakers"`
- `Given the transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve" on 2026-03-15, confirmed` (or `, planned`)
- `When I add the expense "Coffee" of R$ 8.50 to account "Nubank" on 2026-03-15` (also `the purchase`, `the refund`, `the account refund`, `the transfer`, with the same wording as the `Given`)
- `When I type "120+35,90" in the amount`
- `When I edit the purchase "Dinner" to date 2026-03-05` / `When I edit the purchase "Dinner" to R$ 250.00`
- `When I delete the expense "Coffee"` / `When I delete the purchase "Dinner"`
- `When I confirm the expense "Electricity" with amount R$ 203.40 on 2026-03-14` / `When I unconfirm the expense "Groceries"`
- `When I cancel the purchase "TV"` (EST-5) / `When I close the remaining installments of the purchase "TV"` (EST-6)
- `Then the expense "Electricity" is "planned" | "confirmed" | "overdue"` (same for `the purchase`)
- `Then there is the refund "Course" of R$ 800.00 on card "Purple" on 2026-03-15 linked to the purchase "Course"`
- `Then there is no refund linked to the purchase "TV"`
- `Then the overdue badge shows 2`
- `And the expense "Coffee" is daily spending` / `is not daily spending` / `And the expense "Coffee" has the tags "groceries, leisure"`

#### Recurrence and installments
- `Given the recurring income "Salary" of R$ 5,000.00 in account "Nubank", monthly, starting 2026-01-05, with no end`
- `Given the recurring expense "Netflix" of R$ 55.90 on card "Purple", monthly, starting 2026-01-20, for 12 occurrences`
- `Given the recurring transfer "Save" of R$ 500.00 from account "Nubank" to account "Reserve", monthly, starting 2026-03-21, with no end` (or `to card "Purple"`, autopay)
- `When I edit the 2026-05-05 occurrence of series "Salary" with scope "this and following" to R$ 5,500.00`
- `When I confirm the 2026-04-05 occurrence of series "Salary"` (with `with amount R$ 6,200.00 on 2026-04-05`, if it changes)
- `Then the 2026-04-05 occurrence of series "Salary" is "overdue"`
- `Then the 2026-04-05 occurrence of series "Salary" shows position "4/12"`
- `Then the series "Salary" has 12 generated occurrences, from 2026-01-05 to 2026-12-05`
- `Then the series "Salary" has no occurrence on 2026-06-05`
- `When I end the series "Allowance"`
- `Then the installments of the purchase "TV" are:` (table `| k | amount | statement | accrual |`)
- `Then the sum of the installments of the purchase "TV", counting the cancelled ones, is R$ 3,000.00`
- `Then installments 3 to 10 of the purchase "TV" are "cancelled"`

#### Daily budget
- `Given the daily amount is R$ 50.00 since 2026-01-01`
- `Given the daily amount changes to R$ 0.00 from 2026-03-15` / `When I change the daily amount to R$ 60.00 from 2026-03-20`
- `Given the daily budget source is card "Purple"` / `is account "Wallet"` / `is the default account`
- `Then the daily reserve on 2026-03-15 is R$ 20.00`
- `Then the daily budget from 2026-03-01 to 2026-03-15 has budgeted R$ 750.00, spent R$ 600.00 and surplus R$ 150.00` (or `overspend`)

#### Projection and simulation
- `Given the projection horizon is 12 months` (`1 month` in the singular) / `When I change the projection horizon to 6 months`
- `Then the horizon end is 2027-03-15`
- `Then the consolidated projected balance on 2026-04-10 is R$ 700.00` / `Then the consolidated projected balance is:` (table `| date | balance | color |`)
- `Then the projected balance of account "Nubank" on 2026-04-10 is R$ 700.00` / `Then the projected balance of account "Nubank" is:`
- `Then there is no projected balance on 2027-03-16`
- `Then the derived outflow of the 2026-04 statement of card "Purple" is R$ 300.00 on 2026-04-10` (no outflow: `… is R$ 0.00`, without a date)
- `Then the lowest future balance is -R$ 200.00 on 2026-04-10`
- `Then the first negative day is 2026-04-10` / `Then there is no negative day`
- `When I simulate a purchase of R$ 1,200.00 on card "Purple" on 2026-03-15 in 3 installments` (or `in account "Nubank"`, `a daily spending purchase of`)
- `Then the simulation shows the lowest future balance of -R$ 50.00 on 2026-04-04 without the purchase` / `with the purchase`
- `Then the simulation shows the consolidated balance of R$ 2,250.00 on 2026-04-10 with the purchase`
- `Then the simulation shows the first negative day 2026-03-29 with the purchase`
- `When I turn the simulation into an entry titled "Headphones"`

#### Thermometer
- `Given the thermometer is in relative mode with the default multipliers`
- `Then the thermometer color on 2026-03-20 is "yellow"`
- `Then the thermometer thresholds are "-R$ 500.00 · R$ 0.00 · R$ 1,000.00 · R$ 2,000.00"`
- `When I save the thermometer thresholds "-R$ 1,000.00 · R$ 0.00 · R$ 500.00 · R$ 3,000.00"`

#### Tags and indicators
- `Given the tag "groceries" that marks daily spending`
- `When I create the tag "leisure" with the color "blue"` / `When I merge the tag "store" into the tag "groceries"`
- `Then the realized Inflows for 2026-03 are R$ 5,000.00` (same for `Outflows`, `Daily spending`, `Saved`, `Performance`, `savings rate`; the `realized`/`forecast` version is always explicit)
- `Then the realized indicators for 2026-03 are:` (table `| indicator | amount |`)
- `Then the realized savings rate for 2026-03 is not shown`
- `Given the realized Total outflows were:` (table `| month | Total outflows |`)
- `Then the cost of living is R$ 1,620.00`
- `Then the realized tag report for 2026-03 shows:` (table `| tag | expenses | income |`)
- `Then the realized tag report for 2026-03 shows the tag "leisure" with expenses R$ 400.00`
- `Then the tag "leisure" does not appear in the realized tag report for 2026-02`
- `Then the realized Outflows list for 2026-03 shows "Rent" with R$ 1,800.00`

## Notes per area

### accounts

Scenarios for accounts (§1), balance adjustment (§1.1) and the general conventions that apply to accounts (GER-3, GER-5, GER-8, GER-9), including the points where an account rule decides the outcome of another feature.

### credit-cards

Scenarios for cards (§2), statements (§2.1) and limit (§2.2), plus the card purchase status (STA-6), refunds (EST) and credit withdrawal (TRF-8) where they touch statement amounts, limit and credit. Aligned with the v3 rules.

How to read them:

- "the 2026-04 statement" is the **label** (month of the due date). The statement identity is `card + cycle sequence number` (FAT-0). When the identity matters (CAR-5), the scenario gives the statement an alias ("statement A") before the change and follows it by the alias, without depending on where the numbering starts.
- When the scenario uses purchases with a past date, the Background sets the card start date to 2026-01-01 (CAR-8). A card created with `When I create` uses the default (today).

Reference calendar (sample cards):

- `Purple` (closes 3, due 10): 2026-03 statement = cycle `[2026-02-03, 2026-03-03)`, due 2026-03-10 · 2026-04 statement = `[2026-03-03, 2026-04-03)`, due 2026-04-10 · 2026-05 statement = `[2026-04-03, 2026-05-03)`, due 2026-05-10.
- `Black` (closes 28, due 5): 2026-03 statement = `[2026-01-28, 2026-02-28)`, due 2026-03-05 · 2026-04 statement = `[2026-02-28, 2026-03-28)`, due 2026-04-05.
- With today = 2026-03-15, the current open statement (FAT-13) of both is the 2026-04 one.

### entries

Scenarios for creating, validating, editing and deleting expenses, income, refunds, account refunds and transfers, with planned/confirmed status (LAN, STA, EST, TRF, GER-5), per the v3 rules.

### recurrence-installments

Scenarios for recurring series (§3.4, REC) and installment purchases (§3.5, PAR), with rounding (GER-10), idempotent generation (GER-11) and the invariants INV-4 and INV-10. Internal statement details live in `credit-cards/`; here we only check which statement each installment/occurrence falls in and with what amount.

Cards in these scenarios have a start date (CAR-8) of 2026-01-01, explicit in the card step. Statements are referred to by their label (month of the due date, FAT-0).

New steps, beyond this file:
- `Then the first 5 dates of series "X" are "d1, d2, d3, d4, d5"`: the pure calendar of the series (REC-3), independent of the horizon.
- `Then the series "X" has 12 generated occurrences, from 2026-04-05 to 2027-03-05`
- `Then the 2026-04-05 occurrence of series "X" is "planned"` / `shows position "3/12"` / `shows no position`
- `When I delete the 2026-06-10 occurrence of series "X" with scope "this only"`
- `When I change the projection horizon to 6 months` / `When occurrence generation runs again`
- `Given the app has been closed since 2026-03-15` + `When I open the app on 2026-05-25`
- `When I add the expense "Payment Book" of R$ 600.00 to account "Nubank" in 6 installments with installment 1 on 2026-03-31`
- `When I add the purchase "Sofa" to card "Purple" on 2026-03-15 in 3 installments of R$ 333.33`
- `When I prepay 2 installments of the purchase "TV" with a discount of R$ 30.00`
- `When I cancel the purchase "TV"` (EST-5) / `When I close the remaining installments of the purchase "TV"` (EST-6)

### daily-budget-projection

Scenarios for the app's engine: daily amount and reserve (§4), balance projection (§6), the "can I buy it?" simulation (§6.1), thermometer (§7) and INV-9.

### tags-indicators

Scenarios for tags (§5, TAG-1..10), indicators by accrual month (§8, IND-1..12), refunds/account refunds in the indicators and the invariant INV-8, with a full month checked by hand. Aligned with the v3 rules.

### integration

End-to-end scenarios where one action crosses several features and has to match, at the same time, actual balance, projection (per account and consolidated), statements, limit, indicators, tag report, thermometer and invariants (§11).

Reading notes:

- Follows this file. "The YYYY-MM statement" is the **label** (month of the due date, FAT-0); the internal identity is card + cycle sequence number, which does not change when the closing day changes (CAR-5). For `Purple` (closes 3, due 10) the label matches the closing month; for `Black` (closes 28, due 5) the 2026-04 statement closes on 2026-03-28.
- A card with purchases before today is created with a start date earlier than them (usually 2026-01-01), per CAR-8. Only CAR-9 entries ("Pre-app balance", pre-app installments) may have a date before the start date (INV-7 exception).
- `Purple` calendar: 2026-03 statement = `[2026-02-03, 2026-03-03)` due 2026-03-10 · 2026-04 = `[2026-03-03, 2026-04-03)` due 2026-04-10 · 2026-05 = `[2026-04-03, 2026-05-03)` due 2026-05-10.
- Thermometer with the default bands (TER-2) unless the scenario says otherwise. Balances and colors in the tables were checked day by day, with exact arithmetic in cents.
- Does not repeat single-feature scenarios; when a step already exists in the other features, the wording is the same.
