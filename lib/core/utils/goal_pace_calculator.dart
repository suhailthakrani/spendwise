import '../../data/models/goal_status.dart';
import '../../data/models/saving_goal.dart';

/// Pure helpers for monthly save pace and on-track status.
abstract final class GoalPaceCalculator {
  /// Months remaining until [deadline], minimum 1 when still in the future.
  static int monthsRemaining(DateTime? deadline, [DateTime? now]) {
    if (deadline == null) return 0;
    final n = now ?? DateTime.now();
    final start = DateTime(n.year, n.month, 1);
    final end = DateTime(deadline.year, deadline.month, 1);
    final months =
        (end.year - start.year) * 12 + (end.month - start.month);
    if (months < 0) return 0;
    return months == 0 ? 1 : months;
  }

  /// Required save this calendar month for one goal (USD storage).
  static double requiredThisMonth(SavingGoal goal, [DateTime? now]) {
    if (goal.isAchieved || goal.status != GoalStatus.active) return 0;
    final remaining = goal.remaining;
    if (remaining <= 0) return 0;

    if (goal.monthlyTarget != null && goal.monthlyTarget! > 0) {
      return goal.monthlyTarget!.clamp(0.0, remaining);
    }

    final months = monthsRemaining(goal.deadline, now);
    if (months <= 0) {
      // Past deadline or no deadline: suggest finishing remaining this month.
      return remaining;
    }
    return remaining / months;
  }

  /// Sum of required monthly saves across active goals.
  static double totalRequiredThisMonth(
    List<SavingGoal> goals, [
    DateTime? now,
  ]) {
    return goals.fold<double>(
      0,
      (sum, g) => sum + requiredThisMonth(g, now),
    );
  }

  /// Primary goal for banner: soonest deadline, else highest priority.
  static SavingGoal? primaryGoal(List<SavingGoal> goals) {
    final active = goals
        .where((g) => g.status == GoalStatus.active && !g.isAchieved)
        .toList();
    if (active.isEmpty) return null;

    active.sort((a, b) {
      final aDl = a.deadline;
      final bDl = b.deadline;
      if (aDl != null && bDl != null) {
        final cmp = aDl.compareTo(bDl);
        if (cmp != 0) return cmp;
      } else if (aDl != null) {
        return -1;
      } else if (bDl != null) {
        return 1;
      }
      return a.priority.compareTo(b.priority);
    });
    return active.first;
  }
}
