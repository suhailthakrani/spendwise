import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/budget.dart';
import '../data/models/category.dart';
import '../data/models/dashboard_stats.dart';
import '../data/models/expense.dart';
import '../data/models/monthly_summary.dart';
import '../data/models/recurring_expense.dart';
import '../data/models/user_profile.dart';
import 'preferences_providers.dart';
import 'repository_providers.dart';

final categoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});

final expensesProvider = StreamProvider<List<Expense>>((ref) {
  return ref.watch(expenseRepositoryProvider).watchAll();
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchAll();
});

final recurringExpensesProvider = StreamProvider<List<RecurringExpense>>((ref) {
  return ref.watch(recurringExpenseRepositoryProvider).watchAll();
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).watchProfile();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(expensesProvider);
  return ref.watch(reportRepositoryProvider).dashboardStats(currency);
});

final monthlySummariesProvider =
    FutureProvider<List<MonthlySummary>>((ref) async {
  final currency = ref.watch(currencyDisplayProvider);
  ref.watch(expensesProvider);
  return ref.watch(reportRepositoryProvider).monthlySummaries(currency);
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
