# Business rules (spec)

> Source spec, in English. Every rule has a stable id (`CON-1`, `FAT-6`, ...).
> Code, tests and commits reference these ids. [glossary.md](glossary.md) maps every spec term to its code name.
> Executable scenarios live in [../features/](../features/), tagged with these ids.
> When a rule changes, change it here first, then the scenarios, then the code.

Every rule has an id (`CON-1`, `CAR-3`…) so it can be referenced in code, tests and discussion. What changed between versions is in the decision log (§12).

## 0. General conventions

| Id     | Rule |
| ------ | ---- |
| GER-1  | Money is stored as an integer number of **cents**. Never float. |
| GER-2  | Single currency: BRL. Multi-currency is out of scope. |
| GER-3  | Entry dates are **local dates** (no time), in the user's time zone (default `America/Sao_Paulo`). "Today" is computed in that time zone and recomputed at midnight while the app is open. Changing the time zone does not change the date of any entry and does not invalidate saved dates (e.g. an opening balance that becomes "tomorrow" in the new time zone remains valid; a confirmed entry that becomes "tomorrow" stays confirmed, INV-6). When switching the time zone, the app asks for confirmation ("Changing the time zone changes what today is. No entry date will be changed") and, if any confirmed entry ends up dated tomorrow, warns ("1 confirmed entry is now dated tomorrow in the new time zone" / "N confirmed entries are now…"). |
| GER-4  | An entry amount is always **positive**. Direction comes from the type, never from the sign. |
| GER-5  | Entities referenced by entries (account, card) are **archived**, not deleted. Archived items disappear from lists and pickers but remain in reports and history. An entry can be truly deleted, with confirmation and a **5-second "undo"** that restores the same id and `createdAt` (for a transfer, both sides). |
| GER-6  | Every record has `createdAt` and `updatedAt`, and the app shows when the entry was created. |
| GER-7  | The data belongs to the user: export everything (CSV/JSON), including archived items, at any time. |
| GER-8  | Maximum **absolute** value of an entry, installment plan total, opening balance, adjustment difference, limit or daily amount: R$ 99,999,999.99. Internal sums use 64-bit integers. |
| GER-9  | Text is trimmed and **internal whitespace is collapsed** (`Banco  Inter` → `Banco Inter`), on save and on comparison. Whitespace only = empty. Length counts **visible characters** (graphemes, NFC). Name uniqueness compares the **normalized** form: case-insensitive and accent-insensitive. |
| GER-10 | Money arithmetic is **exact** (decimal/rational) and only the final result is rounded, to the cent, **half away from zero** (2.345 → 2.35; −2.345 → −2.35). No cent is lost: the sum of the parts always equals the total. |
| GER-11 | Automatic generation is **idempotent**: every generated item has a stable identity (series + occurrence sequence number; purchase + installment number). Running generation twice, or on two devices, duplicates nothing. |
| GER-12 | **Horizon end** = today + N months (PRJ-3), inclusive. Adding months follows REC-3: a day that does not exist becomes the last day of the month (2026-08-31 + 6 months = 2027-02-28). |
| GER-13 | Note: optional, 0–1,000 characters, trimmed. |

## 1. Accounts

Account = a place where money is held (checking account, wallet, savings, reserve).

**Fields:** name, kind, purpose, opening balance, opening balance date, color/icon, `archived`.

**Kinds:** `checking`, `cash` (physical money), `savings`, `reserve`, `investment`.

**Purpose:** `spending` (money to spend) or `saving` (money not meant to be spent).

| Id     | Rule |
| ------ | ---- |
| CON-1  | Name required (1–40 characters), unique among **active** accounts (GER-9). May repeat the name of an archived one. |
| CON-2  | Opening balance is prefilled with R$ 0.00 (empty = zero), may be negative (overdraft), bounded by GER-8. Opening balance date required, default today, may be in the past, may not be in the future at creation. |
| CON-3  | No entry of the account (income, expense, incoming or outgoing transfer, statement payment, adjustment) may be dated **before** the opening balance date. The same date is allowed. |
| CON-4  | **Actual balance** = opening balance + confirmed income − confirmed expenses + confirmed transfers received − confirmed transfers sent ± adjustments. |
| CON-5  | **Projected balance** on a date D: see §6. |
| CON-6  | Default purpose by kind: checking and cash → `spending`; savings, reserve and investment → `saving`. The user may change it. Changing the **kind** later does not touch the purpose. Only `spending` accounts count toward the consolidated balance, the thermometer and the spending indicators. |
| CON-7  | Changing the opening balance date or amount recomputes the account's whole history. Changing the date to a future date is blocked (as at creation, CON-2). Changing the date to after existing entries is blocked (CON-3) and the app lists the conflicting entries. To fix a difference with the bank **today**, use "Adjust balance" (AJU). |
| CON-8  | Delete only if the account has no entries and is not the payment account of an **active** card. Opening balance ≠ 0 → confirmation showing the amount leaving the consolidated balance. Deleting the default account follows CON-10. If it was the payment account of an archived card, the card is left without an account and requires choosing one when unarchived. |
| CON-9  | Archiving requires: actual balance = 0, **no planned entries** (of any date), no active recurring series, not being the payment account of an active card nor the explicit daily budget source. The app offers to resolve each blocker (transfer the balance out — or in, if negative —, move or delete planned entries, end series, change the card's account). |
| CON-10 | One active `spending` account is the **default account** (preselected when adding entries and the default daily budget source, DIA-10). The first `spending` account created becomes the default. Archiving or deleting the default requires choosing another one first, if another active `spending` account exists. With none, the app has no default until one exists; the next one created, unarchived or switched to `spending` becomes the default. |
| CON-11 | Unarchive: becomes active again if the name does not collide with an active one (otherwise asks to rename). |
| CON-12 | Changing the purpose recomputes the indicators for the whole history, with a warning. Switching to `saving` is blocked if the account is the default account, the daily budget source or a card payment account. Daily-spending flags on its expenses stay saved but are **ignored** while it is `saving`, and apply again if it switches back to `spending`. |
| CON-13 | An archived account and its entries are **read-only**. To change anything, unarchive. |

### 1.1 Balance adjustment

| Id    | Rule |
| ----- | ---- |
| AJU-1 | "Adjust balance" takes the balance the bank shows **today** and creates a confirmed entry, dated today, of the special type `adjustment`, for the difference from the actual balance. A positive difference comes in, a negative one goes out. A difference above GER-8 is blocked. |
| AJU-2 | A zero difference creates nothing. |
| AJU-3 | Before adjusting, the app warns if the account has overdue planned entries **or ones dated today**, or an overdue statement paid from it: the usual cause is forgetting to confirm, not a balance error. |
| AJU-4 | An adjustment is identified by its **type** `adjustment`. It has no tags. It does not count in Inflows, Outflows, Performance, Saved, the tag report or cost of living. Only in the balance. |
| AJU-5 | An adjustment can be deleted. Only its note can be edited. To fix the amount, delete it and adjust again. |

## 2. Credit cards

A card is not an account: a card purchase **does not change the balance** of any account. What changes it is the **statement payment**.

**Fields:** name, limit, closing day, due day, default payment account, start date, color, `archived`.

| Id    | Rule |
| ----- | ---- |
| CAR-1 | Name required (1–40), unique among active cards (GER-9). Limit > 0 and ≤ GER-8. Closing and due days between 1 and 31. |
| CAR-2 | Day 29/30/31 in a short month → last day of the month. |
| CAR-3 | Default payment account required, active and `spending`: it is where the statement's planned outflow comes from in the projection. (If it could be `saving`, card spending would never show up in the consolidated balance.) |
| CAR-4 | Delete only with no entries. With entries → archive. Archiving requires total debt = 0 (no debt and no credit, LIM-1), no planned purchase/card refund, no planned payment and no active recurring series linked to the card. Leftover credit is taken out via "withdraw credit" (TRF-8). |
| CAR-5 | Changing the closing or due day applies from the **current open statement** onward (FAT-13). New closing day: if the new day has not yet arrived this month, the current open statement closes on it; otherwise, next month. Purchases in the open and future statements are reallocated; installments remain one per consecutive statement. Closed statements do not change. Pinned purchases (FAT-2) stay in the same statement. The app shows the new dates before confirming. |
| CAR-6 | Lowering the limit below the current debt is allowed; the available limit becomes negative, with a warning. |
| CAR-7 | Unarchive follows CON-11 and requires a valid payment account (CAR-3). |
| CAR-8 | Card **start date**: default today, may be in the past, may not be in the future. Purchases, card refunds, statement payments and credit withdrawals may not be dated before it (except the entries of CAR-9). Changing it to after existing entries is blocked, listing the conflicts (as CON-7). Prevents creating old "overdue" statements by mistake. |
| CAR-9 | **Start with a card already in use** (at creation or later): (a) **current statement balance** — amount already spent in the open cycle, becomes a "Pre-app balance" purchase dated today in the current open statement; (b) **unpaid closed statement balance** — becomes a "Pre-app balance" dated the day before that statement's closing date; (c) **installment plan in progress** — purchase with the original date, total, N and the current installment k: installments 1..k−1 are recorded as "pre-app installments" (outside statements, limit and indicators, but counting for INV-4 and PAR-2) and k..N go from the current open statement onward, consuming limit. Installment accrual dates follow the rule in §8 (original date + (j−1) months). "Pre-app balance" (a, b) is excluded from the indicators and the tag report. These entries may be dated before the start date (CAR-8). |

### 2.1 Statements

| Id     | Rule |
| ------ | ---- |
| FAT-0  | **Identity:** `card + cycle sequence number`, stable even if the days change (CAR-5). The **label** is the due month ("April statement"). If two statements of the same card have the same label (rare, with closing/due day at month end), the label also shows the closing date ("due 03-31 · closed 02-28"). |
| FAT-1  | **Cycle:** the statement closing on date F contains the purchases dated in `[previous F, F)`. A purchase **on** the closing day or later falls into the next one. ("Best purchase day" = closing day.) |
| FAT-2  | **Move purchase** manually to the next or previous statement, one cycle per action (repeatable), only between **non-closed** statements. The purchase becomes "pinned": a change of closing day does not touch it. Moving it back to its natural cycle unpins it. Changing the purchase date also unpins and reallocates it (with a warning). |
| FAT-3  | **Due date:** first occurrence of the due day (CAR-2) **strictly after** the closing date. (Closes on the 28th, due on the 5th → the 5th of the next month. Closes on the 3rd, due on the 10th → the 10th of the same month.) |
| FAT-4  | **Total** = rolled-over carried-over balance (FAT-9) + **confirmed** purchases and installments of the cycle − confirmed card refunds of the cycle − previous credit (FAT-10). **Outstanding** = total − linked confirmed payments + credit withdrawals (TRF-8, act as a negative payment; the total does not change) + credit already passed on to the next statement (FAT-10). **Planned** purchases and card refunds of the cycle are shown separately ("+ R$ X planned"), not in the total. |
| FAT-5  | **Status** (derived): `open` (today < closing); `closed` (closing ≤ today ≤ due, outstanding > 0); `paid` (outstanding = 0 after closing, with something charged); `overdue` (today > due, outstanding > 0, no answer, FAT-9); `rolledOver` (the remainder went to the next one); `inCredit` (after closing, total < 0: the credit passes to the next one, FAT-10, and the statement stays visible); `empty` (after closing, no **confirmed** entry in the cycle and total = 0, hidden; planned entries moved into it still count in the projection, FAT-11). A statement with closing > today is always `open`, even with total ≤ 0. "Partially paid" is a detail within `closed`/`overdue`. For locks (PAR-4, FAT-2, FAT-12), **closed statement** = any statement with closing ≤ today. |
| FAT-6  | **Derived outflow** in the projection, on the default payment account, on the due date: `max(outstanding + planned purchases of the cycle − planned card refunds of the cycle + daily reserve of the cycle (DIA-10) − linked planned payments, 0)`. If `overdue`, it counts **today** (STA-4). It is not a stored entry. |
| FAT-7  | **Pay statement** = transfer (TRF) from an account to the card, linked to a statement (default: the oldest closed/overdue one; otherwise the current open statement). Suggested amount = the statement's outstanding amount; suggested account = default payment account. It is not an expense: the spending was already counted in the purchases. |
| FAT-8  | Paying the **open** statement (early) is allowed and reduces its outstanding amount. A confirmed payment requires date ≤ today; a planned (scheduled) payment enters the projection in place of the derived outflow (FAT-6). A planned payment larger than the derived outflow: the excess reduces the derived outflow of the following statements, in order, until used up. Scheduling a payment after the due date triggers a warning. |
| FAT-9  | An expired statement with outstanding > 0 becomes `overdue` and the app asks "Did you pay?" → **record payment** or **I didn't pay**: the remainder becomes the _carried-over balance_ of the **immediately following** statement (which keeps its own status) and the current one becomes `rolledOver`, with outstanding 0. While linked planned payments cover the outstanding amount, it does not ask. "I didn't pay" can be undone while the statement that received the balance is open. Interest and fees are entered by the user as a card expense; the app suggests, it does not compute. |
| FAT-10 | A payment above the amount, or a card refund larger than the purchases, creates **credit**. A **closed** statement passes the credit immediately to the next one and is left with outstanding 0. An **open** statement keeps the negative value until it closes (purchases in its own cycle may consume it); in the projection, that negative value already reduces the derived outflow of the following statements, as in FAT-8. |
| FAT-11 | An `empty` statement does not appear in the statements/pending list and does not ask "Did you pay?". An **open** statement with total ≤ 0 still counts in the projection via the FAT-6 formula (planned purchases, daily reserve, credit). |
| FAT-12 | Adding, editing or deleting a purchase or card refund dated in a closed statement is allowed with a warning ("this changes a statement that has already closed"). If the statement was paid, the difference becomes credit (FAT-10) or outstanding. If it was rolled over, the difference goes to the carried-over balance of the statement that received the rollover. Also applies to editing, deleting or unconfirming a **payment** of a statement that is closed, rolled over or has already passed on credit: the credit is withdrawn from the next one (possibly reopening an outstanding amount). |
| FAT-13 | **Current open statement** = the statement with the earliest closing > today. The following ones are **future** (may hold installments and planned purchases). |
| FAT-14 | A recurring transfer to the card (automatic debit) links each occurrence to the statement with the first due date ≥ the occurrence date. |

### 2.2 Limit

| Id    | Rule |
| ----- | ---- |
| LIM-1 | Card **total debt** = Σ outstanding of all statements (open, future and unpaid closed), confirmed only. Equivalent to: confirmed purchases and installments (excluding "pre-app" and cancelled ones) − confirmed card refunds − confirmed payments + credit withdrawals, since the start. A rolled-over balance is **not** added again: it only moved to another statement. **Available limit** = limit − total debt. With credit (negative debt), the available limit exceeds the limit and the screen shows "limit + credit". |
| LIM-2 | A purchase above the available limit is **allowed with a warning** (the bank may have granted extra limit). |
| LIM-3 | **Planned** purchases do not consume limit, but the app shows "available after planned", and a planned purchase exceeding it triggers the LIM-2 warning. |

## 3. Entries

Types: **expense**, **income**, **transfer**, **card refund** and the special **adjustment** (AJU).

**Common fields:** title, amount, date, status, tags, note.

| Id    | Rule |
| ----- | ---- |
| LAN-1 | Title required (1–80 characters, GER-9). Amount > 0 and ≤ GER-8. Date required, default today. |
| LAN-2 | **Expense**: comes out of an active account **or** an active card. |
| LAN-3 | **Income**: goes into an active account. Money coming back from a purchase is a **card refund** (EST), not income. |
| LAN-4 | **Amount field** accepts an expression in pt-BR number format: digits, decimal comma, dot as thousands separator only in groups of 3 (`1.234,56`), operators `+ - − * × x / ÷`, parentheses and unary minus; spaces and "R$" are ignored. Exact arithmetic, only the final result is rounded (GER-10), validated **after** rounding: > 0 and ≤ GER-8. A comma with no digit on one side is valid (`,50` = 0.50; `10,` = 10.00). Division by zero or an invalid expression (`1.5`, `1,234.56`, `abc`) = error. Only the result is stored. |
| LAN-5 | An entry may have 0..N tags (adjustment has none). There is no mandatory category. |
| LAN-6 | An expense on a `spending` account or a card may be flagged as **daily spending** (§4). Default unflagged, or flagged if it has a tag that flags it automatically (TAG-4). Income, transfer, adjustment and expense on a `saving` account cannot be daily spending. |
| LAN-7 | Minimum date: the account's opening balance date (CON-3) or the card's start date (CAR-8). Maximum date: horizon end (GER-12). For an installment plan, applies to the 1st installment; for a recurring series, to the series start. Shortening the horizon does not delete manual entries beyond it (see REC-12 for occurrences). |
| LAN-8 | **Edit:** expense ↔ income may switch; transfer and adjustment do not change type (delete and add again). A card purchase turned into "money back" becomes an unlinked card refund on the same card. Switching between account and card reallocates (leaves the account, enters the statement, or the reverse); a planned/overdue account entry moved to the card with date ≤ today becomes a confirmed purchase (STA-6), with a warning that it consumes limit. Switching to income or to a `saving` account removes the daily-spending flag, with a warning. A purchase/expense with linked card refunds or account refunds cannot change account, card or type (delete the refunds first). Installments and series occurrences follow PAR-4/REC-5. |
| LAN-9 | An entry cannot be created on an archived account or card. Existing ones are read-only (CON-13). |

### 3.1 Status: planned and confirmed

Separate what has already happened from what is still going to happen.

| Id    | Rule |
| ----- | ---- |
| STA-1 | Status: `planned` or `confirmed`. |
| STA-2 | Default on creation: date ≤ today → `confirmed`; date > today → `planned`. The user may switch, respecting STA-8. On edit, moving a planned entry's date into the past keeps it planned (it becomes overdue). |
| STA-3 | `overdue` is **derived**: planned with date < today. It is not stored. |
| STA-4 | In the projection, an overdue entry counts as if it would happen **today** (the money has not left yet, but it will). |
| STA-5 | Confirming allows adjusting the actual date and amount (the electricity bill was planned at 180 and came in at 203.40). The confirmed date cannot be in the future; when confirming a future planned entry, the suggested date is today. |
| STA-6 | **On a card**, purchases and card refunds with date ≤ today are always `confirmed` and cannot be unconfirmed. With a future date they are `planned` (planning): shown separately in the statement (FAT-4), included in the derived outflow (FAT-6), do not touch the limit (LIM-3). When the date arrives, they **confirm automatically** and the app notifies ("confirmed; delete it if it did not happen"). Installments of a confirmed purchase are all confirmed: the debt already exists. |
| STA-7 | Overdue entries produce a badge (a transfer counts as 1) and **one** optional notification per entry, on the day it becomes overdue, until it is confirmed, rescheduled or deleted. |
| STA-8 | **A confirmed entry never has a future date.** A confirmed entry edited to a future date goes back to `planned`, with a warning. |
| STA-9 | Unconfirming (confirmed → planned) is allowed on an account; if the date is in the past, it becomes overdue. On a card, STA-6 applies. |

### 3.2 Card refund and account refund

| Id    | Rule |
| ----- | ---- |
| EST-1 | **Card refund**: money coming back to the card. May be linked to a **confirmed purchase on the same card** with date ≤ the refund date (optional). Falls into the statement of the refund date's cycle (FAT-1). Status follows STA-6. Tags are prefilled with those of the linked purchase and can be changed. |
| EST-2 | A card refund reduces the statement and the debt (LIM-1). If it exceeds the statement amount, it becomes credit (FAT-10). |
| EST-3 | In the indicators, a card refund **reduces Outflows** — or **Daily spending**, if the linked purchase is daily spending **now** (current flag) — in the month of the refund date. An unlinked card refund reduces Outflows. It never counts as an Inflow. It may make the month's Outflows/Daily spending negative. |
| EST-4 | Linked card refunds of a purchase add up to at most its amount. Reducing the purchase below the sum of its refunds is blocked. Deleting the purchase deletes its refunds, with a warning. Unlinked, no cap. |
| EST-5 | **Cancel purchase** (return): installments in open or future statements are cancelled; for installments in closed statements, the difference `Σ of those installments − card refunds already linked` is settled in the current open statement, dated today: positive → linked card refund; negative (more had already been refunded than was charged) → linked charge "Cancellation settlement"; zero → nothing. In the end, the purchase costs R$ 0.00 net. In the indicators, the settlement mirrors EST-3 with the sign flipped: it adds to Outflows (or Daily spending, if the purchase is daily spending now), in the current month. The purchase becomes `cancelled` and the cancelled installments remain recorded (INV-4), but leave the statement, the limit and the indicators. |
| EST-6 | **Close remaining installments** (correct an entry, renegotiate): cancels only the installments in open/future statements (card) or planned/overdue ones (account), **without** generating a card refund. |
| EST-7 | **Account refund**: special income linked to a **confirmed** expense on the same account, with date ≤ the refund date, under the same rules as EST-3 and EST-4 (reduces Outflows/Daily spending, does not count in Inflows) and tags prefilled with those of the expense (EST-1). It enters the account balance as income. |

### 3.3 Transfers

| Id    | Rule |
| ----- | ---- |
| TRF-1 | Source: active account. Destination: active account other than the source, or active card (statement payment, FAT-7). |
| TRF-2 | A transfer is **one** entry with two sides. Editing or deleting affects both together. One side never exists without the other. |
| TRF-3 | A transfer is neither inflow nor outflow: it does not count in Inflows, Outflows or Performance. |
| TRF-4 | A `spending` → `saving` transfer adds to **Saved** (IND-6); `saving` → `spending` subtracts (withdrawal). Between two accounts with the same purpose it does not count. A statement payment from a `spending` account does not count; from a `saving` account (manual payment) it counts as a **withdrawal**. |
| TRF-5 | Has planned/confirmed status like other entries, on both sides at the same time. |
| TRF-6 | Respects CON-3 on **both** sides. |
| TRF-7 | In the consolidated balance (`spending` only), a transfer between two `spending` accounts nets to zero. To `saving` or to the card, it is an outflow from the consolidated balance; from `saving` to `spending`, an inflow. |
| TRF-8 | **Withdraw credit** from the card: transfer from the card to an account, only up to the available credit (negative debt), confirmed only (date ≤ today, cannot be scheduled). It enters the current open statement increasing the outstanding amount (zeroes the credit). On the account it is an inflow; in the consolidated balance, an inflow if the account is `spending`. Used to zero the card before archiving. |

### 3.4 Recurrence

For salary, rent, subscriptions, electricity bill, "save R$ 500 every month".

| Id     | Rule |
| ------ | ---- |
| REC-1  | Applies to expense (account or card), income (account only) and transfer. Frequency: daily, weekly, monthly, yearly, every N days/weeks/months (N from 1 to 99). |
| REC-2  | End: never, until a date (inclusive), or after N occurrences (N from 1 to 999). |
| REC-3  | The series stores the **anchor day**. Day 29/30/31 in a short month → last day of the month, and back to the anchor day in months that have it (01-31 → 02-28 → 03-31). Yearly on 02-29 → 02-28 in a non-leap year. Weekly keeps the weekday. |
| REC-4  | Occurrences are generated as planned up to the horizon end (GER-12) and keep being generated as time passes (GER-11). An occurrence generated late, with date ≤ today (app closed for days), is born planned → overdue (except on a card, REC-9). |
| REC-5  | Editing or deleting an occurrence asks for the scope: **this only**, **this and following**, **all**. |
| REC-6  | "All" and "this and following" **never change confirmed occurrences** (the app warns and suggests "this only" if the selected one is confirmed). Overdue ones are changed: they have not happened yet. |
| REC-7  | An individually edited occurrence becomes "detached" and is not overwritten by series edits. An individually deleted occurrence becomes an exception: it is not generated again and **keeps its slot** in the count (it is not replaced at the end). "Delete all" also deletes unconfirmed detached occurrences. |
| REC-8  | "This and following" splits the series: the original ends at the previous occurrence, a new series starts at this one with the new data. End after N: the new one inherits the remaining ones. Confirmed occurrences after the split point move to the new series unchanged. On the first occurrence, equivalent to "all". |
| REC-9  | A recurring series on a card (subscription) generates one planned purchase per occurrence, each in the statement of its cycle (FAT-1). When the date arrives, it **confirms automatically** (STA-6). Cancelled subscription: the user deletes or ends the series. |
| REC-10 | Each occurrence shows its position `k/N` when there is an end (after N or until a date, with N computed from the full calendar). Numbering follows the **original contract**: after a split (REC-8), the new series continues where it stopped (`5/12`). Confirmed occurrences that fall outside a shortened end stay linked to the series, without a position. "Delete this and following" is equivalent to shortening the end (REC-11): N becomes the last remaining occurrence (`7/7`). |
| REC-11 | Shortening the end (date or N) deletes the planned occurrences left outside. Extending generates the new ones. Confirmed occurrences outside the new end keep existing. |
| REC-12 | **Creating a series that starts in the past:** past occurrences follow STA-2 (born confirmed), with the warning "N past occurrences will be created as confirmed" and the option to create them as planned. Shortening the horizon removes **unedited** planned occurrences beyond the new end (they can be regenerated); detached occurrences and exceptions stay. |

### 3.5 Installments

| Id    | Rule |
| ----- | ---- |
| PAR-1 | Expense only. Number of installments: 2 to 72. **Card:** one installment per consecutive statement, installment 1 in the statement of the purchase date. **Account:** N monthly planned entries (installment booklet, bank slip), the user chooses the 1st installment date, the following ones follow REC-3; each installment is born with status per STA-2. |
| PAR-2 | The user enters the **total amount** or the **installment amount**. From the total: split in cents and the remainder goes to the **first** installment (1,000.00 / 3 = 333.34 + 333.33 + 333.33). Minimum total = N cents (no R$ 0.00 installment). From the installment: total = installment × N. GER-8 applies to the total. |
| PAR-3 | Each installment shows `(k/N)` next to the title. |
| PAR-4 | An installment has no "this only" scope: editing one is editing the purchase. Title, tags, note and daily-spending flag can always be edited and apply to all. Amount, N, date and card only if **no** installment is in a closed statement (card) or confirmed (account); otherwise, EST-5 or EST-6 and add it again. Changing the date so that the 1st installment lands in a closed statement is allowed with the FAT-12 warning, and locks the purchase from then on. |
| PAR-5 | **Prepay installments** (card only): moves the chosen installments (from the last ones backward) to the current open statement. Optional discount, `0 < discount ≤ Σ of prepaid installments`, becomes a linked card refund. The installments' accrual date does not change (§8), only the statement. |
| PAR-6 | A confirmed installment purchase consumes the full limit (LIM-1). A planned installment purchase confirms automatically on its date (STA-6) and then consumes it. |
| PAR-7 | Deleting the purchase deletes all installments (with "undo", GER-5). On a card, an installment in a closed statement applies FAT-12. On an account, a confirmed installment → warning that the actual balance will change. |
| PAR-8 | Installments on an account: each installment is an independent planned entry to confirm (one can be late while another is paid). Confirming with a different amount (interest) is allowed: on an account, the **total is the sum of the installments** (INV-4 still holds). |

## 4. Daily budget (day-to-day spending budget)

The heart of the method. Small expenses are not planned one by one; they are planned as **one amount per day**, the _daily reserve_.

| Id     | Rule |
| ------ | ---- |
| DIA-1  | The user sets the **daily amount** (e.g. R$ 50/day), from R$ 0.00 (off) up to GER-8. |
| DIA-2  | The daily amount has an **effective from** date: a change applies from a date ≥ today. Two changes on the same date: the last one replaces. A future effective-from change can be deleted; one from today or the past cannot. The past keeps the old amount (used in budgeted × spent, DIA-9). |
| DIA-3  | **Automatic suggestion:** confirmed daily spending (minus card refunds and account refunds of daily-spending purchases) in the window `[today − 90, today − 1]` ÷ min(days of use, 90), rounded (GER-10). Days of use = today − creation date of the first account (not the opening balance date); created yesterday = 1 day. With fewer than 30 days of use, no suggestion. Zero spending → suggests R$ 0.00. Suggestion only. |
| DIA-4  | Daily spending entries are ordinary expenses with the LAN-6 flag, on a `spending` account or a card. |
| DIA-5  | **Daily reserve** for a day D ≥ today = max(daily amount effective on D − sum of daily-spending expenses dated D, 0). Counts all daily-spending expenses of that day, confirmed or planned, on account or card. Past days have no reserve. An **overdue** daily-spending planned entry counts today (STA-4) but does not consume today's reserve (its day has already passed). Card refunds and account refunds do not give reserve back. |
| DIA-6  | Today: if 30 of 50 has already been spent, 20 is still reserved for the rest of the day. If 70 was spent, the reserve is 0 (the actual amount is already in the balance or the statement). At midnight, yesterday's surplus is released and today's projected balance goes up; the screen explains it ("surplus from yesterday's daily budget"). |
| DIA-7  | The reserve enters the projection as that day's outflow, **on the daily budget source** (DIA-10). |
| DIA-8  | Daily spending on a card consumes the day's reserve (DIA-5) and the cash effect comes through the statement. This way there is no double counting. |
| DIA-9  | Per day and per month: budgeted (effective amount) × spent (confirmed daily-spending expenses by date, minus card refunds and account refunds of daily-spending purchases on their own dates) and cumulative surplus/overspend from day 1 through today. |
| DIA-10 | **Daily budget source:** by default, "the default account" (follows it if the default changes). Any active `spending` account or active card can be chosen. With a card, each day's reserve enters the derived outflow of that day's cycle statement (FAT-6) — not the statement total nor the limit — and leaves cash on the due date. Archived source → falls back to the default account, with a warning. Reserve for days within the horizon whose due date falls beyond it is shown next to the lowest balance as "R$ X of daily budget in statements beyond the horizon". |

## 5. Tags

| Id     | Rule |
| ------ | ---- |
| TAG-1  | CRUD: name (1–30 characters, GER-9), color (required, with an automatic default) and optional icon. |
| TAG-2  | Name unique **case- and accent-insensitively** (GER-9): `Groceries`, `groceries` and `grocéries` are the same tag. Stored as the user typed it, compared normalized. |
| TAG-3  | Deleting a tag removes it from entries (does not delete entries) and from series templates (it does not come back in future occurrences). The confirmation shows how many entries use the tag: an installment purchase counts as 1; a series counts its generated occurrences. |
| TAG-4  | A tag may automatically flag "daily spending" (LAN-6) when added to an eligible expense, on creation or edit, and on occurrences generated later. Changing this option is not retroactive. Removing the tag does not unflag daily spending. |
| TAG-5  | Inline create: in the entry's tag picker, typing a name that does not exist offers "Create `name`", with an automatic color and no daily-spending flag. If the normalized name already exists, offers the existing one. |
| TAG-6  | Merge: choose source and destination tags (different). All entries (and series templates) of the source move to the destination, without duplicating if they already had both, and the source is deleted. The destination's daily-spending option prevails, without touching the entries. |
| TAG-7  | First use: the app suggests an initial set (groceries, transport, housing, subscription, leisure, health, eating out), offering to turn on the daily-spending flag for groceries and eating out. The user chooses which to create or skips. The suggestion does not come back on its own; it stays in the tag settings. |
| TAG-8  | The picker sorts by usage: number of entries dated in `[today − 89, today]` (no future planned entries), then normalized alphabetical order. |
| TAG-9  | Tag report for the month: sum of expenses and income per tag, under the rules of §8 (accrual date, same realized/forecast selector, `spending` accounts and cards only), with the list of entries. An entry with several tags counts in full in **each** of them (the screen warns that the per-tag total may exceed the month total). Untagged entries appear as "Untagged". Card refunds and account refunds count as negative expense, under their own tags. A tag with no entries in the month does not appear; a tag whose entries sum to R$ 0.00 appears with zero. |
| TAG-10 | Transfers and adjustments are excluded from the report (TRF-3, AJU-4). |

## 6. Balance projection

| Id    | Rule |
| ----- | ---- |
| PRJ-1 | **Starting point:** today's actual balance (CON-4). The past is not projected; it is what happened. |
| PRJ-2 | **Today:** `Balance(today) = actual balance + planned income (≤ today) − planned account expenses (≤ today) ± planned transfers (≤ today) − derived outflows of statements overdue or due today − daily reserve(today)`. An overdue planned statement payment goes out today and reduces its statement's derived outflow. |
| PRJ-3 | **Following days:** `Balance(d) = Balance(d−1) + planned income(d) − planned account expenses(d) ± planned transfers(d) − statement derived outflows(d) − daily reserve(d)`. Default horizon 12 months, configurable from 1 to 24 (GER-12). Statements due after the horizon end are excluded. |
| PRJ-4 | The balance **never resets** at the turn of a month or year. It is a running balance. |
| PRJ-5 | It exists **per account** and **consolidated** (sum of `spending` accounts, TRF-7). The home screen shows the consolidated one. |
| PRJ-6 | Card purchases never appear directly in an account projection, only through the statement's derived outflow (FAT-6). |
| PRJ-7 | Highlights over `[today, horizon end]`: **lowest balance** and its date (the number that answers "am I safe?") and **first negative day**, if any. Tie: the earliest date. Home = consolidated; account screen = that account. |
| PRJ-8 | Anything that changes an entry, account, card, statement, recurring series or daily budget recomputes the projection. The projection is pure: same data + same "today" → same result. |

### 6.1 Simulation: "can I buy it?"

| Id    | Rule |
| ----- | ---- |
| SIM-1 | The user enters amount, date (from today to the horizon end) and payment method (`spending` account or card, single payment or 2–72 installments). Nothing is saved. |
| SIM-2 | The app shows the projection with and without the purchase: lowest balance before × after, and whether any day goes negative (and the first one). |
| SIM-3 | On a card: considers the statement each installment falls into and the available limit (date ≤ today) or the "available after planned" (future date), warning if exceeded (LIM-2). |
| SIM-4 | A simulation flagged as daily spending consumes that day's reserve (DIA-5), just like a real entry. |
| SIM-5 | One tap turns the simulation into a real entry: asks for the title and validates it as a new entry (account/card archived in the meantime → blocked). If the simulated date is now in the past (midnight passed), warns and offers to use today; the user may keep the old date, and then STA-2 applies (born confirmed). |

## 7. Thermometer

| Id    | Rule |
| ----- | ---- |
| TER-1 | Each daily projected balance of the **consolidated** projection gets a color. The per-account projection has no thermometer. |
| TER-2 | The thermometer has **5 fixed colors** and **4 thresholds** in strictly increasing order. Each band is `[lower threshold, upper threshold)`. Default: `< −500` red · `[−500, 0)` pink · `[0, 1,000)` yellow · `[1,000, 2,000)` light green · `≥ 2,000` dark green. A balance of exactly 0 → yellow. |
| TER-3 | The user configures the 4 thresholds. Out-of-order or equal thresholds (empty band) are not saved. |
| TER-4 | **Relative mode:** thresholds as multiples of the monthly cost of living (IND-8). Default: −0.125 · 0 · 0.25 · 0.5 (with a cost of living of R$ 4,000, this yields the same thresholds as the absolute default). Threshold rounded to the cent (GER-10). Cost of living "no data", ≤ R$ 0.00, or producing equal thresholds after rounding → uses the absolute thresholds, with a warning. The whole projection uses the thresholds computed from today's cost of living (threshold = multiplier × already-rounded cost of living). The color of the same balance may change at the turn of the month, when the cost of living is recomputed. |

## 8. Indicators

Computed by **accrual month**: when the spending happened, not when the money left. Account: entry date. Card single payment: purchase date. Installment _k_ (card or account): purchase date (or 1st installment date) + (k−1) months (REC-3), even if prepaid (PAR-5) or confirmed on another date (PAR-8). A one-off account entry uses its own date, including the confirmed date. A statement payment never appears (it is a transfer). Only `spending` accounts and cards count (CON-6). Values may go negative due to card refunds (EST-3); the indicator's list explains it.

| Id     | Indicator      | Rule |
| ------ | -------------- | ---- |
| IND-1  | Inflows        | Income on `spending` accounts in the month. Excludes adjustments, transfers, card refunds and account refunds. |
| IND-2  | Outflows       | Expenses (`spending` account + card) **not** daily spending, minus their card refunds and account refunds (and unlinked card refunds). |
| IND-3  | Daily spending | Daily-spending expenses (account + card), minus card refunds and account refunds of daily-spending purchases. |
| IND-4  | Total outflows | Outflows + Daily spending. |
| IND-5  | Performance    | Inflows − Total outflows. May be negative. |
| IND-6  | Saved          | `spending` → `saving` transfers − withdrawals (`saving` → `spending` and statement payments from `saving`, TRF-4), in the month. May be negative. |
| IND-7  | Savings rate   | Saved ÷ Inflows, one decimal place (GER-10). Inflows = 0 → not shown. Negative values and values above 100% are shown as they are. |
| IND-8  | Cost of living | Average **realized** Total outflows over the last 3 **closed** months (before the current one), counting from the month of the first entry that counts in **any** indicator (including a transfer to `saving`) (partial months and zero months count). With 1 or 2 months, their average. None → "no data". Rounded to the cent (GER-10). |
| IND-9  | Daily average  | Daily spending ÷ days. Current month: days elapsed through today (inclusive), or since the start of use (creation date of the first account, DIA-3) if it began this month. Past month: days in the month. Forecast: forecast Daily spending ÷ days in the month. Future month: forecast version only. Rounded to the cent. |
| IND-10 | —              | Every indicator opens the list of entries that make up the number. Derived ones (savings rate, daily average) open the indicators they are composed of; cost of living opens one item per month. |
| IND-11 | —              | Every indicator has a **realized** version (confirmed with accrual **date** ≤ today) and a **forecast** version (all), for the current and future months. A past month shows only the realized version, with a warning if it has unconfirmed planned entries. The daily reserve does not count in any indicator. |
| IND-12 | —              | Entries on `saving` accounts (yield, fees) do not count in any spending indicator; they appear only in the account statement. |

## 9. Out of scope (for now)

- Statement import (OFX/CSV) and Open Finance — next step after the MVP
- Daily check-in journal (free text for the day)
- Savings goals with a deadline
- Shared account / couple mode
- Investments (quotes, returns)
- Multi-currency
- Automatic interest calculation

## 10. Open questions

- **Platforms and sync:** mobile first (React Native/Expo? Swift?), Mac and web later. Does it need to work offline? If so, the sync model (last-write-wins per record vs CRDT) goes here. GER-11 already guarantees that automatic generation does not duplicate.
- **Login:** local account only at first, or a cloud account from the start?
- **Business model:** free, paid, freemium?

## 11. Invariants

Things that must **always** be true, in any state. They become property tests.

| Id     | Invariant |
| ------ | --------- |
| INV-1  | An account's actual balance = opening balance + Σ effects of its confirmed entries. If cached, recomputing gives the same value. |
| INV-2  | Every transfer nets to zero across its two sides. The total in accounts only changes through income, account refund, account expense, adjustment and transfer to/from a card (statement payment, credit withdrawal). |
| INV-3  | Every single-payment purchase and every confirmed installment on a card belongs to exactly one statement (except "pre-app" and cancelled installments, CAR-9/EST-5). |
| INV-4  | Sum of installments (including cancelled ones) = purchase total, to the cent. |
| INV-5  | Card total debt = Σ outstanding of all statements, confirmed only (credit is negative). |
| INV-6  | No confirmed entry has a future date (exception: up to 1 day, right after switching the time zone westward, GER-3). |
| INV-7  | No entry is dated before the account's opening balance date or the card's start date (except those of CAR-9). |
| INV-8  | Month Performance = Inflows − Outflows − Daily spending. When no entry in the month has more than one tag: Σ expenses in the tag report (including "Untagged") = Total outflows, and Σ income = Inflows, in the same version (realized/forecast). |
| INV-9  | Today's projection with no planned entries, no outstanding statement and a zero daily budget = consolidated actual balance. |
| INV-10 | Regenerating occurrences/installments changes nothing (GER-11). |

## 12. Decision log

### v1 → v2 (initial review)

| #   | Before | Now | Why |
| --- | ------ | --- | --- |
| D1  | `incluirNoTotal` (include in total) | Purpose `spending` / `saving` (CON-6) | A single concept decided three things and could become inconsistent. |
| D2  | Indicators on a cash basis | Accrual (§8) | A statement payment is a transfer; daily spending cannot be separated without apportioning. |
| D3  | Projection subtracted the day's expenses and the actual daily spending | Starts from the actual balance; reserve only from today onward | v1 counted daily spending twice. |
| D4  | Daily spending on a card left open | Consumes the reserve + configurable source | Fixes the double counting. |
| D5  | Adjustment via the `adjustment` tag | Its own type | A tag can be deleted. |
| D6  | Card purchase always confirmed | Future = planned | Plan without consuming limit. |
| D7  | Archiving an account only checked planned entries | Requires zero balance | Archiving with money would change the consolidated balance. |
| D8  | Unpaid statement rolled over on its own | Asks "Did you pay?" | Do not assume silently. |
| D9  | Card refund without rules | EST section | The case that most often breaks statement, limit and indicator. |
| D10 | Bands ambiguous at 0 | `[min, max)` | 0 fell into two bands. |

### v2 → v3 (gaps found by the BDDs)

The 6 BDDs found ~150 gaps. The main decisions:

| #   | Decision | Rules |
| --- | -------- | ----- |
| D11 | **Bug:** the limit counted the rolled-over balance twice. Debt = Σ outstanding of the statements. | LIM-1, INV-5 |
| D12 | **Bug:** a statement identified by its due month collided at the end of February. Identity = card + cycle sequence number (we first tried the closing month, which also collided when the closing day changed); the due month becomes the label. | FAT-0 |
| D13 | Statement total shows only confirmed entries; planned ones separately; the derived outflow adds planned entries and the daily reserve. | FAT-4, FAT-6 |
| D14 | Card gained a **start date** and a **start with a card already in use** flow (statement balance, installment plan in progress). | CAR-8, CAR-9 |
| D15 | The card payment account and the default account must be `spending`. | CAR-3, CON-10 |
| D16 | **Account refund** and a split between _cancel purchase_ (with card refund) and _close remaining installments_ (without card refund). | EST-5, EST-6, EST-7 |
| D17 | Planned card purchase/card refund **confirms automatically** when its date arrives, with a notification. | STA-6 |
| D18 | Realized = confirmed **and** accrual date ≤ today (an April installment is not "realized" in March). | IND-11 |
| D19 | An archived account becomes read-only. | CON-13, LAN-9 |
| D20 | Occurrence identity = series + sequence number (changing the anchor day does not break idempotency). | GER-11 |
| D21 | `k/N` numbering follows the original contract even after splitting the series. | REC-10 |
| D22 | Amount field parser and rounding defined (exact, only at the end, half away from zero). | LAN-4, GER-10 |
| D23 | Thermometer: 5 fixed colors and 4 thresholds; relative mode with default multipliers. | TER-2..4 |
| D24 | The daily budget suggestion divides by min(days of use, 90), not by a fixed 90. | DIA-3 |

**Confirmed taste decisions (2026-10-23):** D15 (require `spending`), D17 (confirm automatically), D21 (contract numbering), D23 (fixed colors in the MVP).
