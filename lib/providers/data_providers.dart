import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/goal_pace_calculator.dart';
import '../data/models/budget.dart';
import '../data/models/budget_period_type.dart';
import '../data/models/category.dart';
import '../data/models/dashboard_stats.dart';
import '../data/models/envelope.dart';
import '../data/models/expense.dart';
import '../data/models/forecast.dart';
import '../data/models/insights_period.dart';
import '../data/models/ledger_entry_type.dart';
import '../data/models/money_log.dart';
import '../data/models/monthly_summary.dart';
import '../data/models/recurring_expense.dart';
import '../data/models/saving_contribution.dart';
import '../data/models/saving_goal.dart';
import '../data/models/transaction_template.dart';
import '../data/repositories/report_repository.dart';
import '../data/services/forecast_service.dart';
import '../data/services/insight_engine.dart';
import 'preferences_providers.dart';
import 'repository_providers.dart';
import 'auth_providers.dart';

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

/// Spending only — expenses tab, budgets, category usage.
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchExpenses();
});

/// Full ledger (expenses + income) for recent activity / search.
final ledgerProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
});

/// Categories ordered by how often they've been used in expenses (most first).
/// Unused categories keep their natural name order after the used ones.
final categoriesByUsageProvider = Provider<List<ExpenseCategory>>((ref) {
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
  if (categories.isEmpty) return const [];

  final counts = <String, int>{};
  for (final expense in expenses) {
    counts[expense.categoryId] = (counts[expense.categoryId] ?? 0) + 1;
  }

  final ranked = [...categories]..sort((a, b) {
      final countCompare = (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0);
      if (countCompare != 0) return countCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  return ranked;
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  // Also depend on expenses so spent/remaining stay in sync with Home.
  ref.watch(expensesProvider);
  return ref.watch(budgetRepositoryProvider).watchAll();
});

/// Selected calendar month on the Budget tab (day ignored). Defaults to now.
final budgetMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final recurringExpensesProvider = StreamProvider<List<RecurringExpense>>((ref) {
  return ref.watch(recurringExpenseRepositoryProvider).watchAll();
});

final envelopesProvider = StreamProvider<List<Envelope>>((ref) {
  return ref.watch(envelopeRepositoryProvider).watchAll();
});

final templatesProvider = StreamProvider<List<TransactionTemplate>>((ref) {
  return ref.watch(templateRepositoryProvider).watchAll();
});

final moneyLogsProvider = StreamProvider<List<MoneyLog>>((ref) {
  return ref.watch(moneyLogRepositoryProvider).watchAll();
});

final userProfileProvider = currentUserProvider;
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(ledgerProvider);
  return ref.watch(reportRepositoryProvider).dashboardStats(currency);
});

final insightsPeriodProvider = StateProvider<InsightsPeriod>((ref) {
  final raw = ref.read(preferencesProvider).valueOrNull?.analyticsPeriod;
  for (final period in InsightsPeriod.values) {
    if (period.name == raw) return period;
  }
  return InsightsPeriod.oneYear;
});

final autoPostQueueProvider = StreamProvider<List<RecurringExpense>>((ref) {
  return ref.watch(recurringExpenseRepositoryProvider).watchAutoPostQueue();
});

final insightsReportProvider = Provider<InsightsReport>((ref) {
  final expenses = ref.watch(ledgerProvider).valueOrNull ?? [];
  final currency = ref.watch(currencyDisplayProvider);
  final period = ref.watch(insightsPeriodProvider);
  return ReportRepository.summarizePeriods(
    period: period,
    expenses: expenses,
    currency: currency,
  );
});

final forecastProvider = FutureProvider<ForecastResult>((ref) async {
  ref.watch(ledgerProvider);
  ref.watch(recurringExpensesProvider);
  ref.watch(activeSavingGoalsProvider);

  final expenses = ref.watch(expenseRepositoryProvider);
  final recurring = ref.watch(recurringExpensesProvider).valueOrNull ?? [];
  final goals = ref.watch(activeSavingGoalsProvider).valueOrNull ?? [];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? [];

  final now = DateTime.now();
  final currentBalance = await expenses.totalBalance();
  final monthSpendSoFar = await expenses.sumForMonth(month: now);
  final monthIncomeSoFar = await expenses.sumForMonth(
    month: now,
    type: LedgerEntryType.income,
  );

  final monthlyBudgetLimit = budgets
      .where(
        (b) =>
            b.periodType == BudgetPeriodType.monthly &&
            b.year == now.year &&
            b.month == now.month &&
            b.categoryId == null,
      )
      .map((b) => b.effectiveLimit)
      .fold<double?>(null, (best, limit) => best ?? limit);

  final recurringInputs = [
    for (final bill in recurring)
      (
        title: bill.title,
        amount: bill.amount,
        due: bill.nextDueDate,
        isIncome: bill.entryType == LedgerEntryType.income,
      ),
  ];

  final goalInputs = <({String title, double amount, DateTime due})>[];
  for (final goal in goals) {
    final remaining = GoalPaceCalculator.remainingToStayOnPace(goal, now);
    if (remaining <= 0) continue;
    final due = goal.deadline ?? DateTime(now.year, now.month + 1, 0);
    goalInputs.add((title: goal.name, amount: remaining, due: due));
  }

  return ForecastService().project(
    currentBalance: currentBalance,
    monthSpendSoFar: monthSpendSoFar,
    monthIncomeSoFar: monthIncomeSoFar,
    monthlyBudgetLimit: monthlyBudgetLimit,
    recurring: recurringInputs,
    goalContributions: goalInputs,
  );
});

final insightsEngineProvider = Provider<MonthlyReview>((ref) {
  final ledger = ref.watch(ledgerProvider).valueOrNull ?? [];
  final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? [];
  final now = DateTime.now();

  final categoryBudgets = <String, double>{
    for (final budget in budgets)
      if (budget.categoryId != null &&
          budget.year == now.year &&
          budget.month == now.month)
        budget.categoryId!: budget.effectiveLimit,
  };
  final categoryNames = <String, String>{
    for (final category in categories) category.id: category.name,
  };

  return const InsightEngine().analyze(
    transactions: [
      for (final e in ledger)
        (
          date: e.date,
          amount: e.amount,
          categoryId: e.categoryId,
          type: e.type.name,
        ),
    ],
    now: now,
    categoryBudgets: categoryBudgets,
    categoryNames: categoryNames,
  );
});

final currentMonthSummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(ledgerProvider);
  return ref.watch(reportRepositoryProvider).currentMonthSummary(currency);
});

final monthlyTrendProvider = FutureProvider<List<double>>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(expensesProvider);
  return ref.watch(reportRepositoryProvider).monthlyTrend(currency);
});

final monthlyTrendLabelsProvider = Provider<List<String>>((ref) {
  return ref.watch(reportRepositoryProvider).monthlyTrendLabels();
});

final expenseDetailProvider =
    StreamProvider.family<Expense?, String>((ref, id) {
  return ref.watch(expenseRepositoryProvider).watchById(id);
});

final categoryExpensesProvider =
    StreamProvider.family<List<Expense>, String>((ref, categoryId) {
  return ref.watch(expenseRepositoryProvider).watchByCategory(categoryId);
});

final budgetDetailProvider = FutureProvider.family<Budget?, String>((ref, id) {
  ref.watch(expensesProvider);
  return ref.watch(budgetRepositoryProvider).getById(id);
});

final savingGoalsProvider = StreamProvider<List<SavingGoal>>((ref) {
  return ref.watch(savingGoalRepositoryProvider).watchAll();
});

final activeSavingGoalsProvider = StreamProvider<List<SavingGoal>>((ref) {
  return ref.watch(savingGoalRepositoryProvider).watchActive();
});

final savingGoalDetailProvider =
    StreamProvider.family<SavingGoal?, String>((ref, id) {
  return ref.watch(savingGoalRepositoryProvider).watchById(id);
});

final goalContributionsProvider =
    StreamProvider.family<List<SavingContribution>, String>((ref, goalId) {
  return ref.watch(savingGoalRepositoryProvider).watchContributions(goalId);
});

/// Monthly save requirement for budget banner (display currency).
final monthlyGoalsPaceProvider = Provider<
    ({
      SavingGoal? primary,
      int activeCount,
      double requiredDisplay,
      double primaryRequiredDisplay,
    })>((ref) {
  final goals = ref.watch(activeSavingGoalsProvider).valueOrNull ?? [];
  final currency = ref.watch(currencyDisplayProvider);
  final primary = GoalPaceCalculator.primaryGoal(goals);
  final requiredUsd = GoalPaceCalculator.totalRequiredThisMonth(goals);
  final primaryUsd = primary == null
      ? 0.0
      : GoalPaceCalculator.remainingToStayOnPace(primary);

  return (
    primary: primary,
    activeCount: goals.length,
    requiredDisplay: currency.toDisplayAmount(requiredUsd),
    primaryRequiredDisplay: currency.toDisplayAmount(primaryUsd),
  );
});
