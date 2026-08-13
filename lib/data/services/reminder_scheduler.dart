import '../models/budget.dart';
import '../models/recurring_expense.dart';
import '../models/saving_goal.dart';
import '../models/user_preferences.dart';
import 'notification_service.dart';

class ReminderScheduler {
  ReminderScheduler(this._notifications);

  final NotificationService _notifications;

  static const _billHour = 9;

  Future<void> sync({
    required UserPreferences prefs,
    required List<RecurringExpense> recurring,
    required List<Budget> budgets,
    required List<SavingGoal> goals,
    required String Function(double amount) formatAmount,
  }) async {
    await _notifications.cancelAll();
    if (!prefs.notificationsEnabled) return;

    if (prefs.billRemindersEnabled) {
      for (final bill in recurring) {
        await _scheduleBill(bill, formatAmount);
      }
    }

    if (prefs.budgetAlertsEnabled) {
      for (final budget in budgets) {
        await _scheduleBudget(budget, formatAmount);
      }
    }

    if (prefs.goalRemindersEnabled) {
      for (final goal in goals) {
        await _scheduleGoal(goal, formatAmount);
      }
    }
  }

  Future<void> cancelAll() => _notifications.cancelAll();

  Future<void> _scheduleBill(
    RecurringExpense bill,
    String Function(double amount) formatAmount,
  ) async {
    final due = DateTime(
      bill.nextDueDate.year,
      bill.nextDueDate.month,
      bill.nextDueDate.day,
      _billHour,
    );
    final amount = formatAmount(bill.amount);

    await _notifications.scheduleAt(
      id: _id('bill_due_${bill.id}'),
      when: due,
      title: 'Bill due today',
      body: '${bill.title} · $amount',
    );

    await _notifications.scheduleAt(
      id: _id('bill_soon_${bill.id}'),
      when: due.subtract(const Duration(days: 1)),
      title: 'Bill due tomorrow',
      body: '${bill.title} · $amount',
    );
  }

  Future<void> _scheduleBudget(
    Budget budget,
    String Function(double amount) formatAmount,
  ) async {
    if (budget.limit <= 0) return;
    if (budget.progress < 0.8) return;

    final now = DateTime.now();
    var when = DateTime(now.year, now.month, now.day, _billHour);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }

    final over = budget.isOverBudget;
    final percent = (budget.progress * 100).round();
    await _notifications.scheduleAt(
      id: _id('budget_${budget.id}_${now.year}_${now.month}'),
      when: when,
      title: over ? 'Over budget' : 'Budget nearly used',
      body: over
          ? '${budget.name} is over by ${formatAmount(budget.spent - budget.limit)}'
          : '${budget.name} is at $percent% (${formatAmount(budget.spent)} of ${formatAmount(budget.limit)})',
    );
  }

  Future<void> _scheduleGoal(
    SavingGoal goal,
    String Function(double amount) formatAmount,
  ) async {
    final deadline = goal.deadline;
    if (deadline == null || goal.isAchieved) return;

    final day = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      _billHour,
    );
    final remaining = formatAmount(goal.remaining);

    await _notifications.scheduleAt(
      id: _id('goal_due_${goal.id}'),
      when: day,
      title: 'Goal deadline',
      body: '${goal.name} · $remaining left',
    );

    await _notifications.scheduleAt(
      id: _id('goal_soon_${goal.id}'),
      when: day.subtract(const Duration(days: 7)),
      title: 'Goal due in 7 days',
      body: '${goal.name} · $remaining left',
    );
  }

  int _id(String key) => key.hashCode & 0x7fffffff;
}
