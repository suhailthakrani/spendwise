import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../data/repositories/recurring_expense_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/user_profile_repository.dart';
import 'database_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(
    ref.watch(databaseProvider),
    ref.watch(expenseRepositoryProvider),
  );
});

final recurringExpenseRepositoryProvider =
    Provider<RecurringExpenseRepository>((ref) {
  return RecurringExpenseRepository(ref.watch(databaseProvider));
});

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return PreferencesRepository(ref.watch(databaseProvider));
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(databaseProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    ref.watch(expenseRepositoryProvider),
    ref.watch(budgetRepositoryProvider),
  );
});
