import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/budget.dart';
import '../data/models/recurring_expense.dart';
import '../data/models/saving_goal.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/expense_repository.dart';
import '../data/repositories/recurring_expense_repository.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../data/services/app_analytics.dart';
import '../data/services/notification_service.dart';
import '../data/services/reminder_scheduler.dart';
import 'auth_providers.dart';
import 'database_provider.dart';
import 'preferences_providers.dart';

final appAnalyticsProvider = Provider<AppAnalytics>((ref) => AppAnalytics());

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(ref.watch(notificationServiceProvider));
});

final _reminderRecurringProvider =
    StreamProvider<List<RecurringExpense>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.value(const []);
  }
  return RecurringExpenseRepository(ref.watch(databaseProvider), userId)
      .watchAll();
});

final _reminderBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.value(const []);
  }
  final db = ref.watch(databaseProvider);
  final expenses = ExpenseRepository(db, userId);
  return BudgetRepository(db, expenses, userId).watchAll();
});

final _reminderGoalsProvider = StreamProvider<List<SavingGoal>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || userId.isEmpty) {
    return Stream.value(const []);
  }
  return SavingGoalRepository(ref.watch(databaseProvider), userId).watchActive();
});

/// Keeps local reminders in sync with prefs and account data.
final reminderBindingProvider = Provider<void>((ref) {
  final prefs = ref.watch(preferencesProvider).valueOrNull;
  final scheduler = ref.watch(reminderSchedulerProvider);
  final notifications = ref.watch(notificationServiceProvider);
  final currency = ref.watch(currencyDisplayProvider);

  if (prefs == null || !prefs.isSignedIn) {
    unawaited(scheduler.cancelAll());
    return;
  }

  final recurring = ref.watch(_reminderRecurringProvider).valueOrNull ?? const [];
  final budgets = ref.watch(_reminderBudgetsProvider).valueOrNull ?? const [];
  final goals = ref.watch(_reminderGoalsProvider).valueOrNull ?? const [];

  unawaited(
    scheduler.sync(
      prefs: prefs,
      recurring: recurring,
      budgets: budgets,
      goals: goals,
      formatAmount: currency.format,
    ),
  );
  unawaited(notifications.setProductUpdates(prefs.productUpdatesActive));
});
