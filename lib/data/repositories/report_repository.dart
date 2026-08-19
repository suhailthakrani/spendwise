import '../../core/utils/currency_display.dart';
import '../models/dashboard_stats.dart';
import '../models/expense.dart';
import '../models/insights_period.dart';
import '../models/monthly_summary.dart';
import 'budget_repository.dart';
import 'expense_repository.dart';

class ReportRepository {
  ReportRepository(this._expenses, this._budgets);

  final ExpenseRepository _expenses;
  final BudgetRepository _budgets;

  static const _monthLabels = InsightsPeriod.monthNames;

  Future<DashboardStats> dashboardStats(CurrencyDisplay currency) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final todayTotalUsd = await _expenses.sumForDay(today);
    final monthTotalUsd = await _expenses.sumForMonth(month: now);

    final allExpenses = await _expenses.search(
      startDate: monthStart,
      toDisplayAmount: currency.toDisplayAmount,
    );

    final categoryTotals = <String, double>{};
    for (final expense in allExpenses) {
      final converted = currency.toDisplayAmount(expense.amount);
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + converted;
    }

    final totalMonthDisplay = currency.toDisplayAmount(monthTotalUsd);
    final categorySpending = categoryTotals.entries
        .map(
          (e) => CategorySpending(
            categoryId: e.key,
            amount: e.value,
            percentage:
                totalMonthDisplay > 0 ? (e.value / totalMonthDisplay) * 100 : 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final recent = await _expenses.search(
      toDisplayAmount: currency.toDisplayAmount,
    );

    final budgets = await _budgets.watchAll().first;
    final monthly = budgets.where((b) => b.categoryId == null).firstOrNull;
    final monthlyBudgetUsd = monthly?.limit ?? 0.0;

    return DashboardStats(
      totalSpentToday: currency.toDisplayAmount(todayTotalUsd),
      totalSpentThisMonth: totalMonthDisplay,
      monthlyBudget: currency.toDisplayAmount(monthlyBudgetUsd),
      categorySpending: categorySpending,
      recentExpenseIds: recent.take(5).map((e) => e.id).toList(),
    );
  }

  Future<MonthlySummary> currentMonthSummary(CurrencyDisplay currency) async {
    return monthSummary(
      month: DateTime.now().month,
      year: DateTime.now().year,
      currency: currency,
    );
  }

  Future<MonthlySummary> monthSummary({
    required int month,
    required int year,
    required CurrencyDisplay currency,
  }) async {
    final reference = DateTime(year, month, 1);
    final totalExpensesUsd = await _expenses.sumForMonth(month: reference);

    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
    final expenses = await _expenses.search(
      startDate: monthStart,
      endDate: monthEnd,
      toDisplayAmount: currency.toDisplayAmount,
    );

    final breakdown = <String, double>{};
    for (final expense in expenses) {
      final converted = currency.toDisplayAmount(expense.amount);
      breakdown[expense.categoryId] =
          (breakdown[expense.categoryId] ?? 0) + converted;
    }

    return MonthlySummary(
      month: month,
      year: year,
      totalIncome: 0,
      totalExpenses: currency.toDisplayAmount(totalExpensesUsd),
      categoryBreakdown: breakdown,
    );
  }

  Future<List<MonthlySummary>> monthlySummaries(
    CurrencyDisplay currency, {
    int months = 12,
  }) async {
    final now = DateTime.now();
    final summaries = <MonthlySummary>[];
    for (var i = 0; i < months; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      summaries.add(
        await monthSummary(
          month: date.month,
          year: date.year,
          currency: currency,
        ),
      );
    }
    return summaries;
  }

  /// Spending for a lookback window, plus oldest-first history buckets.
  static InsightsReport summarizePeriods({
    required InsightsPeriod period,
    required List<Expense> expenses,
    required CurrencyDisplay currency,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    DateTime? earliest;
    for (final expense in expenses) {
      if (earliest == null || expense.date.isBefore(earliest)) {
        earliest = expense.date;
      }
    }

    final buckets = period.historyBuckets(now: n, earliestExpense: earliest);
    final history = [
      for (final bucket in buckets)
        _summarizeBucket(
          period: period,
          bucket: bucket,
          expenses: expenses,
          currency: currency,
        ),
    ];

    final rangeStart =
        buckets.isEmpty ? DateTime(n.year, n.month, 1) : buckets.first.start;
    final rangeEnd = buckets.isEmpty
        ? DateTime(n.year, n.month + 1, 0, 23, 59, 59)
        : buckets.last.end;

    return InsightsReport(
      period: period,
      range: _summarizeBucket(
        period: period,
        bucket: PeriodBucket(
          label: period.rangeCaption,
          shortLabel: period.shortLabel,
          leadingLabel: period.shortLabel,
          start: rangeStart,
          end: rangeEnd,
        ),
        expenses: expenses,
        currency: currency,
      ),
      history: history,
    );
  }

  static PeriodSummary _summarizeBucket({
    required InsightsPeriod period,
    required PeriodBucket bucket,
    required List<Expense> expenses,
    required CurrencyDisplay currency,
  }) {
    var totalUsd = 0.0;
    final breakdownUsd = <String, double>{};
    for (final expense in expenses) {
      if (!bucket.contains(expense.date)) continue;
      totalUsd += expense.amount;
      breakdownUsd[expense.categoryId] =
          (breakdownUsd[expense.categoryId] ?? 0) + expense.amount;
    }

    return PeriodSummary(
      period: period,
      label: bucket.label,
      shortLabel: bucket.shortLabel,
      leadingLabel: bucket.leadingLabel,
      start: bucket.start,
      end: bucket.end,
      totalExpenses: currency.toDisplayAmount(totalUsd),
      categoryBreakdown: {
        for (final entry in breakdownUsd.entries)
          entry.key: currency.toDisplayAmount(entry.value),
      },
    );
  }

  Future<List<double>> monthlyTrend(
    CurrencyDisplay currency, {
    int months = 6,
  }) async {
    final summaries = await monthlySummaries(currency, months: months);
    return summaries.reversed.map((m) => m.totalExpenses).toList();
  }

  List<String> monthlyTrendLabels({int months = 6}) {
    final now = DateTime.now();
    return List.generate(months, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return _monthLabels[date.month - 1];
    }).reversed.toList();
  }
}
