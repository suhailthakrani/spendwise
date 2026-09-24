enum ForecastCommitmentKind { bill, income, goal }

class ForecastCommitment {
  const ForecastCommitment({
    required this.title,
    required this.amount,
    required this.date,
    required this.kind,
  });

  final String title;
  final double amount;
  final DateTime date;
  final ForecastCommitmentKind kind;
}

class ForecastResult {
  const ForecastResult({
    required this.currentBalance,
    required this.monthSpendSoFar,
    required this.monthIncomeSoFar,
    required this.projectedMonthEndSpend,
    required this.projectedMonthEndBalance,
    required this.expectedIncomeRemaining,
    required this.upcomingCommitments,
    required this.safeToSpendToday,
    required this.safeToSpendThisWeek,
    required this.safeToSpendRestOfMonth,
    required this.paceDailySpend,
    required this.assumptions,
    this.budgetExhaustionDate,
  });

  final double currentBalance;
  final double monthSpendSoFar;
  final double monthIncomeSoFar;
  final double projectedMonthEndSpend;
  final double projectedMonthEndBalance;
  final double expectedIncomeRemaining;
  final List<ForecastCommitment> upcomingCommitments;
  final DateTime? budgetExhaustionDate;
  final double safeToSpendToday;
  final double safeToSpendThisWeek;
  final double safeToSpendRestOfMonth;
  final double paceDailySpend;
  final String assumptions;
}

/// Helper inputs for a what-if adjustment expressed as percentages.
class WhatIfScenario {
  const WhatIfScenario({
    required this.name,
    this.adjustSpendPct = 0,
    this.adjustIncomePct = 0,
  });

  final String name;
  /// e.g. 0.10 = +10% spend, -0.20 = −20% spend.
  final double adjustSpendPct;
  final double adjustIncomePct;

  /// Applies percentage deltas to [base] via absolute spend/income deltas.
  ForecastResult apply(ForecastResult base) {
    final spendDelta = base.projectedMonthEndSpend * adjustSpendPct;
    final incomeDelta =
        (base.monthIncomeSoFar + base.expectedIncomeRemaining) *
            adjustIncomePct;
    return ForecastResult(
      currentBalance: base.currentBalance,
      monthSpendSoFar: base.monthSpendSoFar,
      monthIncomeSoFar: base.monthIncomeSoFar,
      projectedMonthEndSpend: base.projectedMonthEndSpend + spendDelta,
      projectedMonthEndBalance:
          base.projectedMonthEndBalance - spendDelta + incomeDelta,
      expectedIncomeRemaining: base.expectedIncomeRemaining + incomeDelta,
      upcomingCommitments: base.upcomingCommitments,
      budgetExhaustionDate: base.budgetExhaustionDate,
      safeToSpendToday:
          (base.safeToSpendToday - spendDelta).clamp(0.0, double.infinity),
      safeToSpendThisWeek:
          (base.safeToSpendThisWeek - spendDelta).clamp(0.0, double.infinity),
      safeToSpendRestOfMonth: (base.safeToSpendRestOfMonth - spendDelta)
          .clamp(0.0, double.infinity),
      paceDailySpend: base.paceDailySpend,
      assumptions: '${base.assumptions}; what-if: $name',
    );
  }
}
