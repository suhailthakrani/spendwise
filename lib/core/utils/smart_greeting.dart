import '../../data/models/dashboard_stats.dart';

/// Short, context-aware home greetings for SpendWise.
///
/// Priority: period milestones → budget alerts → today’s spend → soft praise →
/// time of day.
abstract final class SmartGreeting {
  static String resolve({
    required DashboardStats stats,
    String? userName,
    DateTime? now,
  }) {
    final asOf = now ?? DateTime.now();
    final name = _firstName(userName);

    final milestone = _periodMilestone(stats, asOf, name);
    if (milestone != null) return milestone;

    final alert = _budgetAlert(stats, name);
    if (alert != null) return alert;

    final today = _todayCue(stats, asOf, name);
    if (today != null) return today;

    if (!stats.hasBudget) {
      final nudge = _noBudgetNudge(asOf, name);
      if (nudge != null) return nudge;
    }

    final praise = _budgetPraise(stats, name);
    if (praise != null) return praise;

    return _timeOfDay(asOf, name);
  }

  static String? _periodMilestone(
    DashboardStats stats,
    DateTime asOf,
    String? name,
  ) {
    if (!stats.hasBudgetPeriod) return null;
    final start = stats.budgetPeriodStart!;
    final end = stats.budgetPeriodEnd!;
    final today = DateTime(asOf.year, asOf.month, asOf.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    if (today == startDay) {
      return name == null ? 'New period starts today' : 'New period, $name';
    }
    if (today == endDay) {
      return name == null ? 'Last day of this period' : 'Last day, $name';
    }
    return null;
  }

  static String? _budgetAlert(DashboardStats stats, String? name) {
    if (!stats.hasBudget) return null;

    if (stats.budgetSpent > stats.monthlyBudget) {
      return name == null ? 'Over budget — ease up' : 'Over budget, $name';
    }

    final progress = stats.budgetProgress;
    if (progress >= 0.95) {
      return name == null ? 'Almost at your limit' : 'Almost maxed, $name';
    }
    if (progress >= 0.8) {
      return name == null ? 'Watch your remaining' : 'Stay sharp, $name';
    }
    return null;
  }

  static String? _noBudgetNudge(DateTime asOf, String? name) {
    // Light nudge mid-day only — don't replace every greeting.
    final hour = asOf.hour;
    if (hour < 11 || hour >= 17) return null;
    return name == null
        ? 'Set a budget to stay on track'
        : 'Plan your spend, $name';
  }

  static String? _budgetPraise(DashboardStats stats, String? name) {
    if (!stats.hasBudget) return null;
    if (stats.budgetSpent <= 0) return null;
    if (stats.budgetProgress > 0.25) return null;
    return name == null ? 'Plenty of room left' : 'Looking solid, $name';
  }

  static String? _todayCue(
    DashboardStats stats,
    DateTime asOf,
    String? name,
  ) {
    final hour = asOf.hour;
    final spentToday = stats.totalSpentToday;

    if (spentToday <= 0) {
      if (hour < 11) {
        return name == null ? 'Fresh start today' : 'Fresh start, $name';
      }
      if (hour >= 20) {
        return name == null ? 'Quiet day on spending' : 'Quiet day, $name';
      }
      return null;
    }

    if (stats.hasBudget &&
        stats.budgetProgress < 0.7 &&
        hour >= 12 &&
        hour < 18) {
      return name == null ? 'On track so far' : 'On track, $name';
    }
    return null;
  }

  static String _timeOfDay(DateTime asOf, String? name) {
    final hour = asOf.hour;
    final weekday = asOf.weekday;
    final isWeekend =
        weekday == DateTime.saturday || weekday == DateTime.sunday;

    if (hour < 5) {
      return name == null ? 'Burning the midnight oil' : 'Still up, $name?';
    }
    if (hour < 12) {
      if (isWeekend) {
        return name == null ? 'Happy weekend' : 'Happy weekend, $name';
      }
      return name == null ? 'Good morning' : 'Morning, $name';
    }
    if (hour < 17) {
      return name == null ? 'Good afternoon' : 'Hey, $name';
    }
    if (hour < 21) {
      return name == null ? 'Good evening' : 'Evening, $name';
    }
    return name == null ? 'Winding down' : 'Winding down, $name';
  }

  static String? _firstName(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final first = trimmed.split(RegExp(r'\s+')).first;
    if (first.length < 2) return null;
    return first;
  }
}
