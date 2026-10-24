# Glossary

The spec ([business-rules.md](business-rules.md)) is written in English. Code is **100% English**.
This table fixes the code name for every spec term and is the single source for naming. If a term is missing, add it here before using it in code.

## Accounts

| Term                                                  | Code name                                                              | Rules        | Notes                                |
| ----------------------------------------------------- | ---------------------------------------------------------------------- | ------------ | ------------------------------------ |
| Account                                               | `Account`                                                              | §1           | pt: conta                            |
| Kind (checking, cash, savings, reserve, investment)   | `AccountKind` (`checking`, `cash`, `savings`, `reserve`, `investment`) | §1           | pt: corrente, carteira, poupança…    |
| Purpose `spending` / `saving`                         | `AccountPurpose` (`spending` / `saving`)                               | CON-6        | pt: finalidade dia a dia / guardado  |
| Opening balance / opening balance date                | `openingBalance` / `openingDate`                                       | CON-2, CON-3 | pt: saldo inicial                    |
| Actual balance                                        | `actualBalance`                                                        | CON-4        | only confirmed entries; pt: saldo real |
| Projected balance                                     | `projectedBalance`                                                     | §6           | pt: saldo projetado                  |
| Consolidated balance                                  | `consolidated`                                                         | TRF-7, PRJ-5 | sum of `spending` accounts           |
| Default account                                       | `defaultAccount`                                                       | CON-10       | pt: conta padrão                     |
| Archive / unarchive                                   | `archive` / `unarchive`                                                | GER-5        |                                      |
| Balance adjustment ("Adjust balance")                 | `BalanceAdjustment`                                                    | AJU          | pt: ajuste de saldo                  |

## Credit cards

| Term                                                                    | Code name                                                              | Rules        | Notes                                     |
| ----------------------------------------------------------------------- | ---------------------------------------------------------------------- | ------------ | ----------------------------------------- |
| Credit card                                                             | `CreditCard`                                                           | §2           |                                           |
| Limit / available limit                                                 | `limit` / `availableLimit`                                             | LIM          |                                           |
| Available after planned                                                 | `availableAfterPlanned`                                                | LIM-3, SIM-3 | pt: disponível depois dos previstos       |
| Total debt                                                              | `totalDebt`                                                            | LIM-1        | pt: dívida total                          |
| Closing day / due day                                                   | `closingDay` / `dueDay`                                                | CAR-1        | pt: fechamento / vencimento               |
| Start date                                                              | `startDate`                                                            | CAR-8        | pt: data de início                        |
| Default payment account                                                 | `paymentAccount`                                                       | CAR-3        |                                           |
| Statement                                                               | `Statement`                                                            | FAT-0        | identity = card + `cycleNumber`; pt: fatura |
| Cycle                                                                   | `cycle`                                                                | FAT-1        | pt: ciclo                                 |
| Current open statement / future statement                               | `currentOpen` / `future`                                               | FAT-13       | pt: aberta atual / futura                 |
| Status: open, closed, paid, overdue, rolled over, in credit, empty      | `open`, `closed`, `paid`, `overdue`, `rolledOver`, `inCredit`, `empty` | FAT-5        | pt: aberta, fechada, paga, atrasada, rolada, com crédito, sem gastos |
| Total / outstanding                                                     | `total` / `outstanding`                                                | FAT-4        | pt: valor total / em aberto               |
| Carried-over balance (rolled over)                                      | `carriedOverBalance`                                                   | FAT-9        | pt: saldo anterior (rolado)               |
| Credit                                                                  | `credit`                                                               | FAT-10       |                                           |
| Derived outflow                                                         | `derivedOutflow`                                                       | FAT-6        | pt: saída derivada                        |
| Pay statement                                                           | `payStatement`                                                         | FAT-7        | pt: pagar fatura                          |
| Move purchase / pinned                                                  | `movePurchase` / `isPinned`                                            | FAT-2        | pt: mover compra / fixada                 |
| "Did you pay?" / "I didn't pay"                                         | `paymentCheck` / `markUnpaid`                                          | FAT-9        | pt: "Você pagou?" / "não paguei"          |
| Withdraw credit / credit withdrawal                                     | `withdrawCredit`                                                       | TRF-8        | pt: resgatar crédito                      |
| Start with a card already in use                                        | `cardOnboarding`                                                       | CAR-9        | pt: começar com o cartão em uso           |
| Pre-app balance                                                         | `preAppBalance`                                                        | CAR-9        | pt: saldo anterior ao app                 |
| Pre-app installments                                                    | `preAppInstallments`                                                   | CAR-9 (c)    | pt: parcelas anteriores ao app            |

## Entries

| Term                         | Code name                               | Rules      | Notes                                                       |
| ---------------------------- | --------------------------------------- | ---------- | ----------------------------------------------------------- |
| Entry                        | `Entry`                                 | §3         | never "Transaction" (clashes with DB transactions); pt: lançamento |
| Expense / income             | `Expense` / `Income`                    | LAN-2, LAN-3 | pt: despesa / receita                                     |
| Card purchase                | `CardPurchase`                          | LAN-2      | pt: compra                                                  |
| Single payment               | (no installment plan)                   | §8, SIM-1  | pt: à vista                                                 |
| Transfer                     | `Transfer`                              | TRF        | pt: transferência                                           |
| Card refund                  | `CardRefund`                            | EST-1      | pt: estorno                                                 |
| Account refund               | `AccountRefund`                         | EST-7      | pt: devolução                                               |
| Adjustment                   | `Adjustment`                            | AJU        | pt: ajuste                                                  |
| Status planned / confirmed   | `EntryStatus` (`planned` / `confirmed`) | STA        | pt: previsto / confirmado                                   |
| Overdue                      | `overdue` (derived, never stored)       | STA-3      | pt: atrasado                                                |
| Daily spending (flag)        | `isDailySpending`                       | LAN-6      | pt: do diário                                               |
| Note                         | `note`                                  | GER-13     | pt: observação                                              |
| Cancel purchase / cancelled  | `cancelPurchase` / `cancelled`          | EST-5      | pt: cancelar compra / cancelada                             |
| Cancellation settlement      | `cancellationSettlement`                | EST-5      | pt: acerto de cancelamento                                  |
| Close remaining installments | `closeRemainingInstallments`            | EST-6      | pt: encerrar parcelas restantes                             |

## Recurrence and installments

| Term                                       | Code name                                             | Rules  | Notes                                      |
| ------------------------------------------ | ----------------------------------------------------- | ------ | ------------------------------------------ |
| Recurring series                           | `RecurringSeries`                                     | REC    | pt: recorrência / série                    |
| Occurrence                                 | `Occurrence`                                          | GER-11 | identity = series + `sequence`             |
| Anchor day                                 | `anchorDay`                                           | REC-3  | pt: dia âncora                             |
| End (never / until a date / after N)       | `end` (`never` / `untilDate` / `afterCount`)          | REC-2  | pt: término                                |
| Scope: this only / this and following / all | `EditScope` (`thisOnly` / `thisAndFollowing` / `all`) | REC-5  | pt: só esta / esta e as próximas / todas  |
| Detached / exception                       | `detached` / `skipped`                                | REC-7  | pt: desvinculada / exceção                 |
| Installment plan / installment             | `InstallmentPlan` / `Installment`                     | PAR    | pt: parcelamento / parcela                 |
| Prepay installments                        | `prepayInstallments`                                  | PAR-5  | pt: antecipar parcelas                     |

## Daily budget

| Term                       | Code name                | Rules  | Notes                      |
| -------------------------- | ------------------------ | ------ | -------------------------- |
| Daily budget               | `DailyBudget`            | §4     | pt: diário                 |
| Daily amount               | `dailyAmount`            | DIA-1  | pt: valor diário           |
| Effective from             | `effectiveFrom`          | DIA-2  | pt: vigência               |
| Daily reserve              | `dailyReserve`           | DIA-5  | pt: reserva diária         |
| Daily budget source        | `dailyBudgetSource`      | DIA-10 | pt: origem do diário       |
| Budgeted × spent           | `budgeted` × `spent`     | DIA-9  | pt: orçado × gasto         |
| Surplus / overspend | `surplus` / `overspend` | DIA-6, DIA-9 | pt: sobra / estouro  |
| Days of use                | `daysOfUse`              | DIA-3, IND-9 | pt: dias de uso      |

## Projection, thermometer, indicators

| Term                                   | Code name                              | Rules         | Notes                                   |
| -------------------------------------- | -------------------------------------- | ------------- | --------------------------------------- |
| Projection                             | `Projection`                           | §6            | pt: projeção                            |
| Horizon / horizon end                  | `horizonMonths` / `horizonEnd`         | PRJ-3, GER-12 | pt: horizonte                           |
| Lowest balance / first negative day    | `lowestBalance` / `firstNegativeDay`   | PRJ-7         | pt: menor saldo / primeiro dia negativo |
| Simulation ("can I buy it?")           | `Simulation`                           | SIM           | pt: "posso comprar?"                    |
| Thermometer / thresholds / bands       | `Thermometer` / `thresholds` / `bands` | TER           | pt: termômetro / cortes / faixas        |
| Colors: red, pink, yellow, light green, dark green | `bands` order                | TER-2         | pt: vermelho, rosa, amarelo, verde claro, verde forte |
| Relative mode                          | `relativeMode`                         | TER-4         | pt: modo relativo                       |
| Accrual date / accrual month           | `accrualDate`                          | §8            | pt: competência                         |
| Realized / forecast                    | `realized` / `forecast`                | IND-11        | pt: realizado / previsto                |
| Inflows                                | `inflows`                              | IND-1         | pt: entradas                            |
| Outflows                               | `outflows`                             | IND-2         | pt: saídas                              |
| Daily spending (indicator)             | `dailySpending`                        | IND-3         | pt: diário (indicador)                  |
| Total outflows                         | `totalOutflows`                        | IND-4         | pt: saída total                         |
| Performance                            | `performance`                          | IND-5         |                                         |
| Saved / withdrawal                     | `saved` / `withdrawal`                 | IND-6, TRF-4  | pt: guardado / resgate                  |
| Savings rate                           | `savingsRate`                          | IND-7         | pt: % economizado                       |
| Cost of living                         | `costOfLiving`                         | IND-8         | pt: custo de vida                       |
| Daily average                          | `dailyAverage`                         | IND-9         | pt: média diária                        |
| Tag report / "Untagged"                | `tagReport` / `untagged`               | TAG-9         | pt: relatório por tag / "Sem tag"       |

## General

| Term        | Code name                         | Rules  | Notes                                    |
| ----------- | --------------------------------- | ------ | ---------------------------------------- |
| Cents       | `Money` (integer cents, `bigint`) | GER-1  | pt: centavos                             |
| Local date  | `LocalDate`                       | GER-3  |                                          |
| Today       | `clock.today()`                   | GER-3  | never `new Date()` in domain/application |
| Time zone   | `timeZone`                        | GER-3  | pt: fuso                                 |
| Invariant   | invariant (`INV-n`)               | §11    |                                          |

## Interaction and UI terms

| Term | Code name | Rules | Notes |
|---|---|---|---|
| Add (an entry) | `addEntry` | LAN | the verb for every entry kind; pt: lançar |
| Account ledger | `accountLedger` | IND-12 | never "statement" (that is a card statement); pt: extrato |
| Picker | `picker` | TAG-5, TAG-8 | account, card, tag and source pickers; pt: seletor |
| Pending items | `pendingItems` | CON-9, CAR-4 | archive flow; pt: pendências |
| Current statement balance / closed unpaid statement balance | `currentStatementBalance` / `closedUnpaidBalance` | CAR-9 | pt: saldo da fatura atual / da fatura fechada não paga |
| Ongoing installment purchase | `ongoingInstallmentPurchase` | CAR-9 | pt: parcelado em andamento |
| Inflow / outflow adjustment | `BalanceAdjustment.direction` (`in` / `out`) | AJU | pt: ajuste de entrada / de saída |
| Linked charge | `linkedCharge` | EST-5 | cancellation settlement as a charge; pt: cobrança vinculada |
| Unlinked refund | `CardRefund` without `linkedPurchaseId` | EST-1 | pt: estorno sem vínculo |
| Multipliers | `multipliers` | TER-4 | pt: multiplicadores |
| Daily spending flag | `isDailySpending` | LAN-6 | pt: marca do diário |
| Label | `label` | FAT-0 | pt: rótulo |
| Position (k/N) | `position` | REC-10, PAR-3 | pt: posição |
| Reschedule / unconfirm | `reschedule` / `unconfirm` | STA-7, STA-9 | pt: remarcar / desconfirmar |
| Daily amount suggestion | `dailyAmountSuggestion` | DIA-3 | pt: sugestão de valor diário |
| Overdue badge / overdue notification | `overdueBadge` / `overdueNotification` | STA-7 | |
| Statement payment | `StatementPayment` | FAT-7 | pt: pagamento de fatura |
| Single payment | `singlePayment` | PAR-1, SIM-1 | pt: à vista |
| Source / destination | `source` / `destination` | TRF-1 | pt: origem / destino |
| Entry type | `EntryType` | LAN | account uses "kind" (`AccountKind`) |
| Device | `device` | GER-11 | |
| Revolving interest | not modeled | FAT-9 | entered by the user as an expense; pt: juros do rotativo |
| Spending account / saving account | `AccountPurpose` | CON-6 | prose for accounts by purpose |
| Creation date | `createdAt` | GER-6, DIA-3 | |
