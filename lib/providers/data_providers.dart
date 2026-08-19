import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/goal_pace_calculator.dart';
import '../data/models/budget.dart';
import '../data/models/category.dart';
import '../data/models/dashboard_stats.dart';
import '../data/models/expense.dart';
import '../data/models/insights_period.dart';
import '../data/models/monthly_summary.dart';
import '../data/models/recurring_expense.dart';
import '../data/models/saving_contribution.dart';
import '../data/models/saving_goal.dart';
import '../data/repositories/report_repository.dart';
import 'preferences_providers.dart';
import 'repository_providers.dart';
import 'auth_providers.dart';

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
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

final recurringExpensesProvider = StreamProvider<List<RecurringExpense>>((ref) {
  return ref.watch(recurringExpenseRepositoryProvider).watchAll();
});

final userProfileProvider = currentUserProvider;
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(expensesProvider);
  return ref.watch(reportRepositoryProvider).dashboardStats(currency);
});

final insightsPeriodProvider =
    StateProvider<InsightsPeriod>((ref) => InsightsPeriod.oneYear);

final insightsReportProvider = Provider<InsightsReport>((ref) {
  final expenses = ref.watch(expensesProvider).valueOrNull ?? [];
  final currency = ref.watch(currencyDisplayProvider);
  final period = ref.watch(insightsPeriodProvider);
  return ReportRepository.summarizePeriods(
    period: period,
    expenses: expenses,
    currency: currency,
  );
});

final currentMonthSummaryProvider = FutureProvider<MonthlySummary>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(expensesProvider);
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
  final primaryUsd =
      primary == null ? 0.0 : GoalPaceCalculator.requiredThisMonth(primary);

  return (
    primary: primary,
    activeCount: goals.length,
    requiredDisplay: currency.toDisplayAmount(requiredUsd),
    primaryRequiredDisplay: currency.toDisplayAmount(primaryUsd),
  );
});
