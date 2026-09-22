# SpendWise — Product & Architecture Plan

Target: evolve SpendWise from an **expense tracker** into a **personal financial management system**.

This document is the execution contract. It records (a) what already exists, (b) what we build next
and in what order, (c) what we deliberately defer, and (d) the architectural decisions that make the
later phases possible. We execute one phase at a time, and we do not start a phase until its
predecessor's Definition of Done is met.

Status as of writing: app version `1.4.0+8`, Drift schema version `6`, 8 tables, offline-first with an
encrypted (SQLCipher) local database.

---

## 1. Where SpendWise stands today

Audit of the 17 proposed systems against the current codebase.

| # | System | Status | Evidence / gap |
|---|---|---|---|
| 1 | Ultra-fast capture | **Partial** | Full add/edit expense screen with amount formatter and category chips. No quick-add, templates, favourites, receipt scan, voice, split, or bulk entry. Offline entry works by design (local DB). |
| 2 | Complete money management | **Expense-only** | `expenses`, `categories`, `recurring_expenses` exist. No income, no accounts/wallets, no balances, no transfers, no debt tracking, no tags, no attachments. Currency is a single display currency converted from a USD base with hardcoded rates. |
| 3 | Advanced budgeting | **Basic** | Monthly budgets scoped by `year`/`month`, overall + per-category, `spent` computed live from expenses, budget alert notifications. No weekly/yearly/custom periods, rollover, envelopes, event budgets, or reallocation. |
| 4 | Financial outlook / forecasting | **Missing** | No projections, no safe-to-spend, no cash-flow forecast, no what-if. Blocked on balances + income (system 2). |
| 5 | Advanced analytics | **Partial** | Insights periods (1M/3M/6M/1Y/all), monthly history buckets, monthly trend, category breakdown, `fl_chart`. No MoM/YoY comparison, velocity, averages, distribution, or account/income trends. Aggregation runs in Dart over loaded rows, not SQL. |
| 6 | Smart insights | **Missing** | No detection engine, no narrative output, no monthly review. |
| 7 | Financial planning | **Good** | Saving goals, contributions, deadlines, monthly target, pace calculator, goal reminders, wishlist fields. Missing emergency-fund template, purchase planning, what-if. |
| 8 | Financial calendar | **Missing** | Only `nextDueDate` on recurring items. No calendar surface. |
| 9 | Recurring & subscriptions | **Partial** | Recurring bills with frequency + reminders (overdue / due today / upcoming). Bills do **not** auto-post to expenses. No subscription intelligence, annualised cost, or cancellation analysis. |
| 10 | Extreme customization | **Missing** | Dashboard, entry form, and analytics layouts are all fixed. |
| 11 | Privacy & security | **Strong** | Offline-first, SQLCipher-encrypted DB with Keystore-backed key, legacy plaintext DB cleanup, local password hashing, biometric **sign-in**, per-user row scoping, account deletion with data wipe. Missing app-lock-on-resume, private mode, PDF reports, CSV/JSON export surface (Excel only today). |
| 12 | Backup & sync | **Backup only** | Google Drive backup + restore, JSON snapshot model (`BackupSnapshot`, `formatVersion`), local file save/pick via `file_picker`, `lastBackupAt`. No automatic/scheduled backup, no backup passphrase, no multi-device sync, no conflict resolution. |
| 13 | Shared finance | **Missing** | Intentionally not started. |
| 14 | AI assistant | **Missing** | No AI surface. Depends on systems 2–6 for useful answers. |
| 15 | Powerful search | **Basic** | Note text match + category + date range + sort, executed in Dart. No amount operators, tag search, natural-language ranges, or full-text index. |
| 16 | Reports | **Partial** | Reports + monthly summary screens, Excel export with range/preview. No PDF, no annual/budget/account/savings reports, no income-vs-expense. |
| 17 | History / progress | **Partial** | Monthly and yearly history buckets exist. No milestones, YoY comparison, or savings-growth timeline. |

**Honest summary:** the foundation is better than most v1 apps — encrypted local storage, clean
repository/provider layering, goals, budgets, reminders, backup, auth. The ceiling is set by one
thing: **the data model only knows about money leaving.** Forecasting, cash-flow calendar, real
analytics, and AI all need income, accounts, and balances. That is the first thing we fix.

---

## 2. Architectural decisions that gate everything else

These are not features. They are the decisions that determine whether phases 3–11 are cheap or
impossible. All four land in Phase 0.

### ADR-1 — Move from an expense table to a transaction ledger

Replace `expenses` with a `transactions` table carrying a `type` discriminator
(`expense` | `income` | `transfer`), plus `accountId` and `toAccountId`. Add an `accounts` table with
opening balance and type (cash / bank / card / wallet). Balance is **derived** from the ledger, never
stored as a mutable truth.

Why now: every later system reads from this shape. Migrating 5k rows at schema v7 is a one-day job;
migrating after we've built forecasting, calendar, analytics, and AI on top of `expenses` is a
multi-week rewrite. The existing `Expense` model stays as a façade over the ledger during migration
so screens change independently of storage.

### ADR-2 — Store money as integer minor units

Amounts are `REAL` today. Summing doubles for money accumulates error and will produce visibly wrong
totals once we add balances, rollovers, and projections that chain arithmetic. Migrate to `INTEGER`
minor units with a `Money` value type that owns rounding and formatting.

### ADR-3 — Make rows sync-ready before we need sync

Add `createdAt`, `updatedAt`, and soft-delete `deletedAt` to every user-owned table, and record writes
in a `change_log`. Multi-device sync (Phase 9) is only tractable with per-row versioning and
tombstones. Retrofitting them later means we cannot reconcile edits made before the upgrade.

Sequencing note: these columns ride along with the ledger migration rather than shipping first.
Adding them means touching every insert and update path, and the ledger migration rewrites those same
paths — doing it twice would double the risk for no gain.

### ADR-5 — Settings belong to an account, not to the device

Delivered, see section 3a. Per-account settings live in `user_settings`; only genuinely device-wide
state (active session, onboarding, biometric binding) stays in `app_preferences`. Callers keep reading
one merged `UserPreferences`, so this stayed invisible to the UI.

### ADR-4 — Aggregate in SQL, not in Dart

`monthlySummaries` currently loops N months, and each iteration loads and folds rows in Dart;
`search` filters text and sorts in memory after fetching. This is fine at a few hundred rows and
falls over at a few years of history. Move aggregation to SQL `GROUP BY` queries and add indexes on
`(user_id, date)`, `(user_id, category_id)`, `(user_id, account_id)` before analytics grows.

Also in Phase 0: currency rates are compiled-in constants (`rateFromUsd`). Multi-currency accounts
need a rate table with an `asOf` date, and historical transactions must keep the rate used at entry
time so past reports don't silently change.

---

## 3a. Shipped: account-scoped settings (schema v7)

The first slice, chosen because it was the one multi-user defect that could silently leak one person's
data to another.

**The defect:** `app_preferences` was a single row for the whole device. Theme, all five notification
toggles, and the Google Drive backup identity (`backupDriveEmail`, `backupDriveFileId`,
`lastBackupAt`) lived there. Everything else was already correctly user-scoped — per-user `userId`
columns, namespaced starter category ids, `_requireUserId` on every repository provider, per-user
deletion — so a second account would have inherited exactly those shared settings, including pointing
its backups at the first account's Drive file.

**What changed:**

- New `user_settings` table keyed by `userId`, holding theme, the notification toggles, and the Drive
  backup identity. `app_preferences` now holds only device state: active session, onboarding, and the
  biometric binding (deliberately device-level — one local account unlocks with this device's
  biometrics).
- `PreferencesRepository` reads both tables through one left-joined query and returns the same merged
  `UserPreferences` as before, so no screen or provider changed. Writes route to the correct table;
  theme is also mirrored onto the device row so splash and sign-in look right before a session exists.
- Every sign-in path creates the account's settings row (`setActiveUserId` is the choke point, with
  `signUp` and the Google paths seeding it too). Closing an account deletes its settings row.
- Backups are `formatVersion` 2 and carry account settings; version 1 files still restore and get
  defaults. Drive linkage is deliberately excluded from backups — it belongs to the device that
  authorised it, not to the data.
- Indexes on the `(user_id, …)` paths every query filters by: expenses by date and by category,
  budgets by period, recurring by due date, goals by status, contributions by goal, categories by user.

**Existing users are unaffected.** The migration copies the current settings onto the signed-in
account before dropping the old columns, guards against a stale session id that no longer matches a
profile, and gives any other local profile defaults rather than the first account's settings.

**Tests:** `test/migration_v6_to_v7_test.dart` builds a real schema-6 database and asserts the
upgrade preserves the account's settings, device state, and ledger, drops the moved columns, creates
the indexes, and survives a stale session. `test/user_scoped_settings_test.dart` covers two-account
isolation, Drive re-linking, signed-out fallback, biometric scope, and settings deletion.
`test/backup_service_test.dart` covers version 1 and 2 restores.

**Deferred with reasons:** audit columns and `change_log` (ADR-3) and the `Money` conversion (ADR-2)
move to Phase 0b, where the same write paths are already being rewritten.

## 3. Roadmap

Ordering principle: **capture → model → understand → forecast → personalise → protect → intelligence.**
Each phase is shippable on its own and leaves the app in a releasable state.

### Phase 0a — Account-scoped settings (shipped, schema v7)

See section 3a for detail. Multi-user correctness and the cheap parts of ADR-4.

### Phase 0b — Ledger people need (schema v8) — **shipped**

Not an architecture dump. Only what users open a finance app for, and what unblocks
priority phases 1, 3, 4, 5, 7.

**Shipped:**
- **Accounts** with a default Cash wallet per user.
- **Income as well as expenses** (`type`: expense | income | transfer-ready).
- **Balance** derived from opening + income − expenses — hero on the dashboard.
- **Real month income** in reports (`MonthlySummary.totalIncome`).
- Expense / Income toggle on the add form; existing expense flows unchanged.
- Safe migration: every existing expense lands on that user’s Cash account; totals unchanged.
- Backup `formatVersion` 3 includes accounts + type/account fields; still restores v1/v2.

**Parked (not user-urgent):**
- Tags, attachments, receipt OCR
- Soft-delete / `change_log` (sync Phase 9)
- Integer minor-unit rewrite (ADR-2)
- Full multi-currency accounts, debt tracking, multi-account management UI
- SQL rewrite of every aggregate (indexes in place; GROUP BY with Phase 4)

**DoD:** met — migration + balance + backup tests green.

### Phase 1 — Ultra-fast capture

- Quick-add sheet: numeric keypad first, last-used category preselected, one-tap save.
- Transaction templates and favourite/recent transactions.
- Entry defaults in preferences: default account, category, currency, visible fields.
- Bulk entry mode; receipt image attachment (OCR deferred to a later phase).
- Recurring bills gain "post now" → creates the real transaction and advances `nextDueDate`.

**DoD:** median time from app open to saved expense under 3 seconds; template and quick-add paths
covered by widget tests.

### Phase 2 — Complete money management

- Income and transfers as first-class entries; account balances derived from the ledger.
- Multiple accounts with per-account currency; debt (borrowed/lent) tracking.
- Tags and notes on all transaction types; attachments surfaced in detail screens.
- Recurring income; bill auto-post with a confirmation queue.

**DoD:** account balances reconcile to the ledger in property tests; income appears in
`MonthlySummary.totalIncome` (currently hardcoded `0`).

### Phase 3 — Forecast engine + financial calendar

- `ForecastService` (pure, unit-tested, no UI dependency): projected month-end spend, projected
  balance, expected income, upcoming commitments, budget-exhaustion date, "at this pace" figures,
  what-if scenarios.
- Dashboard outlook card: current balance → expected commitments → projected month-end balance.
- Safe-to-spend (today / this week / rest of month).
- Financial calendar screen: income dates, bills, planned expenses, budget periods, savings
  contributions, expected balance per day, cash-flow timeline.

**DoD:** forecast covered by deterministic unit tests with injected clock; calendar renders a year of
data without frame drops.

### Phase 4 — Analytics v2, insights engine, powerful search

- Comparisons: this month vs last, same month last year, YoY; category and account trends.
- Metrics: spending velocity, average daily spend, average transaction size, highest/lowest periods,
  distribution, budget performance.
- Interactive charts with drill-down from chart segment to filtered transaction list.
- `InsightEngine`: rule-based detectors (unusual spend, acceleration, category overspend, recurring
  amount change, income change) producing ranked, human-readable insights and a monthly review.
- Search v2: structured query parser (`above 5000`, `last 3 months`, `cash`, tag/account terms) backed
  by SQLite FTS5 on notes, tags, and payees.

**DoD:** every detector has fixture-based tests including the "no insight" case; search returns in
under 100 ms on a 20k-transaction fixture.

### Phase 5 — Budgeting v2

- Weekly / monthly / yearly / custom-period budgets; account budgets; event/temporary budgets.
- Rollover budgets and envelope budgeting with allocation and reallocation.
- Budget history and budget-vs-actual reporting; spending limits distinct from budgets.

**DoD:** rollover arithmetic verified across period boundaries; no double counting when a budget
period and an envelope overlap.

### Phase 6 — Recurring & subscription management

- Subscription view over recurring items: renewal dates, monthly vs annualised cost.
- Subscription spend analysis; dormant/forgotten subscription detection.
- Cancellation what-if ("cancel this → projected saving per year").

### Phase 7 — Extreme customization

- Dashboard widget registry: user picks and orders balance, safe-to-spend, forecast, budgets, goals,
  recent transactions, calendar, charts, insights, accounts.
- Persisted layout in preferences; analytics defaults (period, metrics, categories, accounts, chart
  type); quick actions.

**DoD:** layout survives restore from backup; unknown widget ids degrade gracefully after downgrade.

### Phase 8 — Privacy hardening & reports

- App lock on resume (PIN + biometric) with a configurable grace period; private mode that masks
  amounts.
- Automatic and scheduled backup; passphrase-encrypted backup files.
- Export surface: CSV and JSON alongside Excel; PDF reports (monthly, annual, budget, category,
  account, income-vs-expense, savings, tax-style).
- Explicit "delete everything" flow with confirmation and verification.

### Phase 9 — Backup & sync

- Multi-device sync on top of the Phase 0 `change_log`: last-writer-wins per field with a conflict
  queue for ambiguous cases; encrypted payloads; sync state surfaced in the UI.

### Phase 10 — AI financial assistant

- Natural-language questions answered over the user's own data. Architecture: the model never sees
  raw rows — it selects from a fixed set of typed, local query tools (spend by category/period,
  forecast, affordability, budget proposal) and phrases the result.
- Explicit opt-in, clear disclosure of what leaves the device, and a fully local fallback for the
  common question set.

### Phase 11 — Shared finance

Shared wallets, family budgets, splitting, member permissions, shared goals. Deliberately last: it
introduces multi-user identity, permissions, and server-side state, and it is only worth building
once the single-user experience is excellent.

---

## 4. Active priority track (user-selected)

Priority outcomes: **1, 3, 4, 5, 7** from the remains list — Phase 1, 3, 4, 5, and 7.

| Priority | Phase | Outcome |
|---|---|---|
| 1 | **1** | Ultra-fast expense capture |
| 2 | **3** | Forecast + financial calendar |
| 3 | **4** | Analytics v2 + insights + search |
| 4 | **5** | Budgeting v2 (rollover, envelopes) |
| 5 | **7** | Customizable dashboard |

**Build order (dependencies, not preference):**

```text
0b (ledger) ──► 1 (capture) ──► 3 (forecast/calendar)
                     │                │
                     └──────► 4 (analytics) ──► 5 (budgets v2) ──► 7 (customize)
```

- **0b is still required first.** Phases 3–5 need accounts/income/balances (or at least a ledger shape). Skipping 0b would mean rebuilding them later.
- **Phase 2 (full money management)** is not a priority outcome, but a **thin slice** of it rides inside 0b + 3: at least one account balance, income entries enough for projected month-end, and derived balances. Full multi-wallet / debt / transfers stay deferred.
- **Parked until this track is done:** Phase 2 remainder, 6 (subscriptions), 8–11 (privacy hardening, sync, AI, shared).

### The 10 power features → where they land

| Power feature | Phase | On priority track? |
|---|---|---|
| 1. Ultra-fast expense capture | 1 | **Yes** |
| 2. Advanced budgeting & envelopes | 5 | **Yes** |
| 3. Financial outlook / forecasting | 3 | **Yes** |
| 4. Cash-flow calendar | 3 | **Yes** |
| 5. Advanced analytics & interactive graphs | 4 | **Yes** |
| 6. Smart spending insights | 4 | **Yes** (ships with Phase 4) |
| 7. Savings & financial goals | mostly done; polish in 3/5 | baseline + polish |
| 8. Recurring / subscription management | 1 (auto-post) + 6 | auto-post only with Phase 1; full UI parked |
| 9. Deep customization | 7 | **Yes** |
| 10. Privacy, offline-first, backup | mostly done; 8 + 9 | parked |
| AI assistant (layer on top) | 10 | parked |

---

## 5. Deliberately deferred

Not "never" — just not before the priority track is excellent.

- Phase 2 remainder: multi-wallet UX, debt, full transfers (thin income/account slice only for forecast).
- Phase 6: subscription intelligence (Phase 1 may still auto-post bills).
- Phases 8–11: app lock/PDF hardening, multi-device sync, AI, shared finance.
- Voice entry and natural-language **entry** (Phase 1 ships templates and quick-add instead; NL entry
  rides on the Phase 4 parser).
- Receipt OCR (attachment capture lands in Phase 1; extraction follows Phase 4).
- Split expenses beyond a simple two-way split.
- Anything requiring a backend beyond Firebase auth/messaging and Drive backup, because
  "your money, your device, your data" is the product's positioning and every server-side feature
  spends some of that credibility.

---

## 6. Risks to manage

| Risk | Mitigation |
|---|---|
| Ledger migration corrupts real user data | Ship Phase 0 behind a migration test suite + schema verifier; back up automatically to Drive before migrating; keep a one-release rollback path. |
| Float → integer money migration rounds badly | Convert with explicit rounding rules and assert round-trip totals per user in the migration. |
| Feature surface grows faster than the design system | Every phase adds to shared widgets, not per-screen one-offs; dashboard widgets get a registry in Phase 7. |
| Forecast numbers look wrong to users | Show the inputs behind every projection; never present a projection without its assumption ("based on 12 days of this month"). |
| Analytics jank on long histories | SQL aggregation (ADR-4), pagination, `RepaintBoundary` on charts, and a 20k-transaction performance fixture in CI. |
| Notification fatigue as alert sources multiply | One reminder scheduler owns all scheduling (already true); per-category opt-outs and daily caps. |
| AI erodes the privacy promise | Local pre-aggregation, tool-restricted access, opt-in, and a local-only answer path for common questions. |

---

## 7. How we execute

1. One phase at a time on the **priority track**: 0b → 1 → 3 → 4 → 5 → 7.
2. Each phase starts with a short scope note appended to this file (what's in, what's out, schema
   delta) and ends with its DoD checked.
3. Schema changes always ship with: a Drift migration, a schema-verifier test, a backup
   `formatVersion` review, and a restore test from the previous version.
4. Pure logic (forecast, insights, budgets, money) lives in testable services with an injected clock
   and no Flutter imports.
5. Repositories stay the only door to data; screens never touch the database.
6. Every phase leaves the app releasable — no long-lived feature branches.

### Immediate next step

Phase **1** — ultra-fast capture (quick-add) on the ledger foundation. Keep it to what people
actually use daily: amount → category → save in under a few seconds.

### Known unrelated issue

`test/widget_test.dart` fails at HEAD and still fails: it pumps the app against a fresh in-memory
database, where onboarding is incomplete, so the router correctly redirects to onboarding and the
dashboard assertions never match. Giving the test a signed-in fixture gets it to the dashboard but
then `pumpAndSettle` never completes, so the dashboard has something that never stops animating or a
stream that never closes. Worth fixing on its own, alongside the Phase 1 capture work that will touch
the dashboard anyway.
