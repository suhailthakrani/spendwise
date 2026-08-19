import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/budget_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/recurring_expense_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../data/repositories/user_profile_repository.dart';
import '../data/services/backup_service.dart';
import '../data/services/biometric_auth_service.dart';
import '../data/services/export_service.dart';
import '../data/services/google_auth_service.dart';
import '../data/services/google_drive_backup_client.dart';
import 'database_provider.dart';
import 'preferences_providers.dart';

String _requireUserId(Ref ref) {
  final userId = ref.watch(preferencesProvider).valueOrNull?.activeUserId;
  if (userId == null || userId.isEmpty) {
    throw StateError('Signed-in user required');
  }
  return userId;
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider), _requireUserId(ref));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(databaseProvider), _requireUserId(ref));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final userId = _requireUserId(ref);
  return BudgetRepository(
    ref.watch(databaseProvider),
    ref.watch(expenseRepositoryProvider),
    userId,
  );
});

final recurringExpenseRepositoryProvider =
    Provider<RecurringExpenseRepository>((ref) {
  return RecurringExpenseRepository(
    ref.watch(databaseProvider),
    _requireUserId(ref),
  );
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

final savingGoalRepositoryProvider = Provider<SavingGoalRepository>((ref) {
  return SavingGoalRepository(
    ref.watch(databaseProvider),
    _requireUserId(ref),
  );
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    expenseRepository: ref.watch(expenseRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

final googleDriveBackupClientProvider =
    Provider<GoogleDriveBackupClient>((ref) {
  return GoogleDriveBackupClient(
    signIn: ref.watch(googleAuthServiceProvider).signInClient,
  );
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});
