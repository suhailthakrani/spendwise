import '../../core/utils/currency_display.dart';
import '../models/dashboard_stats.dart';
import '../models/monthly_summary.dart';
import 'budget_repository.dart';
import 'expense_repository.dart';

class ReportRepository {
  ReportRepository(this._expenses, this._budgets);

  final ExpenseRepository _expenses;
  final BudgetRepository _budgets;

  static const _monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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
            percentage: totalMonthDisplay > 0
                ? (e.value / totalMonthDisplay) * 100
                : 0,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final recent = await _expenses.search(
      toDisplayAmount: currency.toDisplayAmount,
    );

    final budgets = await _budgets.watchAll().first;
    final monthlyBudgetUsd = budgets.isNotEmpty ? budgets.first.limit : 0.0;

    return DashboardStats(
      totalSpentToday: currency.toDisplayAmount(todayTotalUsd),
      totalSpentThisMonth: totalMonthDisplay,
      monthlyBudget: currency.toDisplayAmount(monthlyBudgetUsd.toDouble()),
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
    final totalExpensesUsd =
        await _expenses.sumForMonth(month: reference);

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

  Future<List<MonthlySummary>> monthlySummaries(CurrencyDisplay currency) async {
    final now = DateTime.now();
    final summaries = <MonthlySummary>[];
    for (var i = 0; i < 6; i++) {
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

  Future<List<double>> monthlyTrend(CurrencyDisplay currency) async {
    final summaries = await monthlySummaries(currency);
    return summaries.reversed.map((m) => m.totalExpenses).toList();
  }

  List<String> monthlyTrendLabels() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final date = DateTime(now.year, now.month - i, 1);
      return _monthLabels[date.month - 1];
    }).reversed.toList();
  }
}
