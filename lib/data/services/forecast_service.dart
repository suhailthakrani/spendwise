import '../models/forecast.dart';

/// Cash-flow projection for the current calendar month.
///
/// Pure Dart — inject [clock] for deterministic tests.
class ForecastService {
  ForecastService({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  ForecastResult project({
    required double currentBalance,
    required double monthSpendSoFar,
    required double monthIncomeSoFar,
    required double? monthlyBudgetLimit,
    required List<({String title, double amount, DateTime due, bool isIncome})>
        recurring,
    required List<({String title, double amount, DateTime due})>
        goalContributions,
    DateTime? asOf,
  }) {
    final now = asOf ?? _clock();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysElapsed = now.day.clamp(1, daysInMonth);
    final daysLeft = (daysInMonth - daysElapsed).clamp(0, daysInMonth);

    final paceDailySpend =
        daysElapsed > 0 ? monthSpendSoFar / daysElapsed : 0.0;
    var projectedMonthEndSpend = paceDailySpend * daysInMonth;
    // Never project below what has already been spent.
    if (projectedMonthEndSpend < monthSpendSoFar) {
      projectedMonthEndSpend = monthSpendSoFar;
    }

    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month, daysInMonth, 23, 59, 59);
    final asOfDay = DateTime(now.year, now.month, now.day);

    bool dueLaterThisMonth(DateTime due) {
      final d = DateTime(due.year, due.month, due.day);
      return !d.isBefore(monthStart) &&
          !d.isAfter(monthEnd) &&
          d.isAfter(asOfDay);
    }

    final commitments = <ForecastCommitment>[];
    var expectedIncomeRemaining = 0.0;
    var upcomingExpenseCommitments = 0.0;

    for (final item in recurring) {
      if (!dueLaterThisMonth(item.due)) continue;
      if (item.isIncome) {
        expectedIncomeRemaining += item.amount;
        commitments.add(
          ForecastCommitment(
            title: item.title,
            amount: item.amount,
            date: item.due,
            kind: ForecastCommitmentKind.income,
          ),
        );
      } else {
        upcomingExpenseCommitments += item.amount;
        commitments.add(
          ForecastCommitment(
            title: item.title,
            amount: item.amount,
            date: item.due,
            kind: ForecastCommitmentKind.bill,
          ),
        );
      }
    }

    for (final goal in goalContributions) {
      if (!dueLaterThisMonth(goal.due)) continue;
      upcomingExpenseCommitments += goal.amount;
      commitments.add(
        ForecastCommitment(
          title: goal.title,
          amount: goal.amount,
          date: goal.due,
          kind: ForecastCommitmentKind.goal,
        ),
      );
    }

    commitments.sort((a, b) => a.date.compareTo(b.date));

    // Pace already embeds spend-so-far; only project the remaining pace gap.
    // Known upcoming bills/goals are layered on top of discretionary pace.
    final remainingProjectedSpend =
        (projectedMonthEndSpend - monthSpendSoFar).clamp(0.0, double.infinity);

    final projectedMonthEndBalance = currentBalance -
        remainingProjectedSpend +
        expectedIncomeRemaining -
        upcomingExpenseCommitments;

    final budgetRemaining = monthlyBudgetLimit == null
        ? null
        : (monthlyBudgetLimit - monthSpendSoFar);

    // Prefer budget headroom; otherwise use projected surplus if positive.
    final safePool = budgetRemaining ??
        (projectedMonthEndBalance > 0 ? projectedMonthEndBalance : 0.0);
    final safeToSpendRestOfMonth = safePool.clamp(0.0, double.infinity);

    final safeToSpendToday = daysLeft > 0
        ? safeToSpendRestOfMonth / daysLeft
        : safeToSpendRestOfMonth;

    final weekday = now.weekday; // 1=Mon … 7=Sun
    final daysLeftInWeek = (7 - weekday + 1).clamp(1, 7);
    final weekCap = safeToSpendToday * daysLeftInWeek;
    final safeToSpendThisWeek =
        weekCap < safeToSpendRestOfMonth ? weekCap : safeToSpendRestOfMonth;

    DateTime? budgetExhaustionDate;
    if (monthlyBudgetLimit != null &&
        paceDailySpend > 0 &&
        monthSpendSoFar < monthlyBudgetLimit) {
      final remainingBudget = monthlyBudgetLimit - monthSpendSoFar;
      final daysUntilExhaustion = remainingBudget / paceDailySpend;
      final exhaustionDay = now.day + daysUntilExhaustion.floor();
      if (exhaustionDay <= daysInMonth) {
        budgetExhaustionDate = DateTime(
          now.year,
          now.month,
          exhaustionDay.clamp(1, daysInMonth),
        );
      }
    }

    return ForecastResult(
      currentBalance: currentBalance,
      monthSpendSoFar: monthSpendSoFar,
      monthIncomeSoFar: monthIncomeSoFar,
      projectedMonthEndSpend: projectedMonthEndSpend,
      projectedMonthEndBalance: projectedMonthEndBalance,
      expectedIncomeRemaining: expectedIncomeRemaining,
      upcomingCommitments: List.unmodifiable(commitments),
      budgetExhaustionDate: budgetExhaustionDate,
      safeToSpendToday: safeToSpendToday,
      safeToSpendThisWeek: safeToSpendThisWeek,
      safeToSpendRestOfMonth: safeToSpendRestOfMonth,
      paceDailySpend: paceDailySpend,
      assumptions: 'based on $daysElapsed days of this month',
    );
  }

  /// Absolute spend/income deltas applied to an existing projection.
  ForecastResult whatIf(
    ForecastResult base, {
    double spendDelta = 0,
    double incomeDelta = 0,
  }) {
    final projectedSpend = base.projectedMonthEndSpend + spendDelta;
    final expectedIncome = base.expectedIncomeRemaining + incomeDelta;
    final projectedBalance =
        base.projectedMonthEndBalance - spendDelta + incomeDelta;

    final rest = (base.safeToSpendRestOfMonth - spendDelta)
        .clamp(0.0, double.infinity);
    final today =
        (base.safeToSpendToday - spendDelta).clamp(0.0, double.infinity);
    final week =
        (base.safeToSpendThisWeek - spendDelta).clamp(0.0, double.infinity);

    return ForecastResult(
      currentBalance: base.currentBalance,
      monthSpendSoFar: base.monthSpendSoFar,
      monthIncomeSoFar: base.monthIncomeSoFar,
      projectedMonthEndSpend: projectedSpend < base.monthSpendSoFar
          ? base.monthSpendSoFar
          : projectedSpend,
      projectedMonthEndBalance: projectedBalance,
      expectedIncomeRemaining: expectedIncome < 0 ? 0 : expectedIncome,
      upcomingCommitments: base.upcomingCommitments,
      budgetExhaustionDate: base.budgetExhaustionDate,
      safeToSpendToday: today,
      safeToSpendThisWeek: week,
      safeToSpendRestOfMonth: rest,
      paceDailySpend: base.paceDailySpend,
      assumptions: base.assumptions,
    );
  }
}
