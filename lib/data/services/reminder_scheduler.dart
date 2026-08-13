import 'dart:async';

import '../../core/utils/goal_pace_calculator.dart';
import '../models/budget.dart';
import '../models/recurring_expense.dart';
import '../models/saving_goal.dart';
import '../models/user_preferences.dart';
import 'notification_service.dart';

class ReminderScheduler {
  ReminderScheduler(this._notifications);

  final NotificationService _notifications;

  static const _hour = 9;
  static const _debounce = Duration(milliseconds: 600);
  static const _maxPaceGoals = 3;

  Timer? _debounceTimer;
  Future<void>? _inFlight;
  var _cancelQueued = false;
  Set<int> _managedIds = {};
  final Set<int> _sessionShown = {};
  final Map<String, double> _lastBudgetProgress = {};

  void scheduleSync({
    required UserPreferences prefs,
    required List<RecurringExpense> recurring,
    required List<Budget> budgets,
    required List<SavingGoal> goals,
    required String Function(double amount) formatAmount,
  }) {
    _cancelQueued = false;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      unawaited(
        _run(
          isCancel: false,
          work: () => sync(
            prefs: prefs,
            recurring: recurring,
            budgets: budgets,
            goals: goals,
            formatAmount: formatAmount,
          ),
        ),
      );
    });
  }

  void scheduleCancel() {
    _debounceTimer?.cancel();
    _cancelQueued = true;
    unawaited(_run(isCancel: true, work: cancelAll));
  }

  Future<void> _run({
    required bool isCancel,
    required Future<void> Function() work,
  }) async {
    while (_inFlight != null) {
      await _inFlight;
    }
    if (_cancelQueued && !isCancel) return;
    final done = work();
    _inFlight = done;
    try {
      await done;
    } finally {
      if (identical(_inFlight, done)) _inFlight = null;
    }
  }

  Future<void> sync({
    required UserPreferences prefs,
    required List<RecurringExpense> recurring,
    required List<Budget> budgets,
    required List<SavingGoal> goals,
    required String Function(double amount) formatAmount,
  }) async {
    if (!prefs.notificationsEnabled) {
      await cancelAll();
      return;
    }

    final now = DateTime.now();
    final plans = <_ReminderPlan>[
      if (prefs.billRemindersEnabled)
        ...recurring.expand((bill) => _billPlans(bill, formatAmount, now)),
      if (prefs.budgetAlertsEnabled)
        ...budgets.expand((budget) => _budgetPlans(budget, formatAmount, now)),
      if (prefs.goalRemindersEnabled) ...[
        ...goals.expand((goal) => _deadlinePlans(goal, formatAmount)),
        ..._pacePlans(goals, formatAmount, now),
      ],
    ];

    final desiredIds = plans.map((plan) => plan.id).toSet();
    for (final id in _managedIds.difference(desiredIds)) {
      await _notifications.cancel(id);
    }

    final pending = await _notifications.pendingIds();
    for (final plan in plans) {
      if (plan.immediate) {
        if (_sessionShown.add(plan.id)) {
          await _notifications.showNow(
            id: plan.id,
            title: plan.title,
            body: plan.body,
          );
        }
        continue;
      }

      final when = plan.when;
      if (when == null || !when.isAfter(now)) continue;
      if (pending.contains(plan.id)) continue;

      await _notifications.scheduleAt(
        id: plan.id,
        when: when,
        title: plan.title,
        body: plan.body,
      );
    }

    _managedIds = desiredIds;
  }

  Future<void> cancelAll() async {
    _debounceTimer?.cancel();
    await _notifications.cancelAll();
    _managedIds = {};
    _sessionShown.clear();
    _lastBudgetProgress.clear();
  }

  List<_ReminderPlan> _billPlans(
    RecurringExpense bill,
    String Function(double amount) formatAmount,
    DateTime now,
  ) {
    final dueDay = DateTime(
      bill.nextDueDate.year,
      bill.nextDueDate.month,
      bill.nextDueDate.day,
    );
    final dueNine = DateTime(dueDay.year, dueDay.month, dueDay.day, _hour);
    final amount = formatAmount(bill.amount);
    final today = DateTime(now.year, now.month, now.day);
    final plans = <_ReminderPlan>[];

    if (dueDay.isBefore(today)) {
      plans.add(
        _ReminderPlan(
          id: _id('bill_overdue_${bill.id}'),
          title: 'Bill overdue',
          body: '${bill.title} · $amount',
          immediate: true,
        ),
      );
      return plans;
    }

    if (dueDay == today && !dueNine.isAfter(now)) {
      plans.add(
        _ReminderPlan(
          id: _id('bill_due_now_${bill.id}_${_dayKey(today)}'),
          title: 'Bill due today',
          body: '${bill.title} · $amount',
          immediate: true,
        ),
      );
    } else {
      plans.add(
        _ReminderPlan(
          id: _id('bill_due_${bill.id}'),
          when: dueNine,
          title: 'Bill due today',
          body: '${bill.title} · $amount',
        ),
      );
    }

    plans.add(
      _ReminderPlan(
        id: _id('bill_soon_${bill.id}'),
        when: dueNine.subtract(const Duration(days: 1)),
        title: 'Bill due tomorrow',
        body: '${bill.title} · $amount',
      ),
    );
    return plans;
  }

  List<_ReminderPlan> _budgetPlans(
    Budget budget,
    String Function(double amount) formatAmount,
    DateTime now,
  ) {
    if (budget.limit <= 0) return const [];

    final previous = _lastBudgetProgress[budget.id];
    _lastBudgetProgress[budget.id] = budget.progress;

    final crossed80 = previous != null && previous < 0.8 && budget.progress >= 0.8;
    final crossed100 =
        previous != null && previous < 1.0 && budget.progress >= 1.0;
    final monthKey = '${now.year}_${now.month}';
    final plans = <_ReminderPlan>[];

    if (crossed100) {
      plans.add(
        _ReminderPlan(
          id: _id('budget_over_${budget.id}_$monthKey'),
          title: 'Over budget',
          body:
              '${budget.name} is over by ${formatAmount(budget.spent - budget.limit)}',
          immediate: true,
        ),
      );
    } else if (crossed80) {
      final percent = (budget.progress * 100).round();
      plans.add(
        _ReminderPlan(
          id: _id('budget_warn_${budget.id}_$monthKey'),
          title: 'Budget nearly used',
          body:
              '${budget.name} is at $percent% (${formatAmount(budget.spent)} of ${formatAmount(budget.limit)})',
          immediate: true,
        ),
      );
    } else if (budget.progress >= 0.8) {
      var when = DateTime(now.year, now.month, now.day, _hour);
      if (!when.isAfter(now)) {
        when = when.add(const Duration(days: 1));
      }
      final over = budget.isOverBudget;
      final percent = (budget.progress * 100).round();
      plans.add(
        _ReminderPlan(
          id: _id('budget_${budget.id}_$monthKey'),
          when: when,
          title: over ? 'Over budget' : 'Budget nearly used',
          body: over
              ? '${budget.name} is over by ${formatAmount(budget.spent - budget.limit)}'
              : '${budget.name} is at $percent% (${formatAmount(budget.spent)} of ${formatAmount(budget.limit)})',
        ),
      );
    }

    return plans;
  }

  List<_ReminderPlan> _deadlinePlans(
    SavingGoal goal,
    String Function(double amount) formatAmount,
  ) {
    final deadline = goal.deadline;
    if (deadline == null || goal.isAchieved) return const [];

    final day = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      _hour,
    );
    final remaining = formatAmount(goal.remaining);
    return [
      _ReminderPlan(
        id: _id('goal_due_${goal.id}'),
        when: day,
        title: 'Goal deadline',
        body: '${goal.name} · $remaining left',
      ),
      _ReminderPlan(
        id: _id('goal_soon_${goal.id}'),
        when: day.subtract(const Duration(days: 7)),
        title: 'Goal due in 7 days',
        body: '${goal.name} · $remaining left',
      ),
    ];
  }

  List<_ReminderPlan> _pacePlans(
    List<SavingGoal> goals,
    String Function(double amount) formatAmount,
    DateTime now,
  ) {
    final primary = GoalPaceCalculator.primaryGoal(goals);
    final selected = <SavingGoal>[];
    if (primary != null) selected.add(primary);
    for (final goal in goals) {
      if (selected.length >= _maxPaceGoals) break;
      if (selected.any((g) => g.id == goal.id)) continue;
      selected.add(goal);
    }

    final first = DateTime(now.year, now.month, 1, _hour);
    final mid = DateTime(now.year, now.month, 15, _hour);
    final nextFirst = DateTime(now.year, now.month + 1, 1, _hour);
    final plans = <_ReminderPlan>[];

    for (final goal in selected) {
      final required = GoalPaceCalculator.requiredThisMonth(goal, now);
      if (required <= 0) continue;
      final amount = formatAmount(required);
      final when = first.isAfter(now)
          ? first
          : mid.isAfter(now)
              ? mid
              : nextFirst;
      final isMid = when == mid;
      plans.add(
        _ReminderPlan(
          id: _id('goal_pace_${goal.id}_${when.year}_${when.month}_${when.day}'),
          when: when,
          title: 'Saving reminder',
          body: isMid
              ? 'Halfway through the month — set aside $amount for ${goal.name}'
              : 'Set aside $amount for ${goal.name} this month',
        ),
      );
    }
    return plans;
  }

  int _id(String key) => key.hashCode & 0x7fffffff;

  String _dayKey(DateTime day) => '${day.year}${day.month}${day.day}';
}

class _ReminderPlan {
  const _ReminderPlan({
    required this.id,
    required this.title,
    required this.body,
    this.when,
    this.immediate = false,
  });

  final int id;
  final DateTime? when;
  final String title;
  final String body;
  final bool immediate;
}
