/// Pure helpers for carrying unused budget into the next period and
/// attributing category spend across envelopes vs period budgets.
abstract final class BudgetRollover {
  /// Returns the amount to carry into the next period.
  static double unusedToRollover({
    required double limit,
    required double spent,
    required double priorRollover,
    required bool enabled,
  }) {
    if (!enabled) return 0;
    final unused = limit + priorRollover - spent;
    return unused > 0 ? unused : 0;
  }

  /// Effective limit including rollover.
  static double effectiveLimit({
    required double limit,
    required double rolloverAmount,
  }) {
    return limit + rolloverAmount;
  }

  /// When a period budget and an envelope both cover the same category spending,
  /// spent should only count once toward reporting — return the amount
  /// attributable to the envelope without double-counting against the period
  /// budget's remaining.
  static double envelopeSpendWithoutDoubleCount({
    required double categorySpend,
    required double envelopeAllocated,
    required double periodBudgetLimit,
  }) {
    if (categorySpend <= 0) return 0;
    // Envelope owns up to its allocation; excess is period-budget only.
    final envelopeShare =
        categorySpend < envelopeAllocated ? categorySpend : envelopeAllocated;
    // Cap attribution so we never claim more than the period budget itself
    // would cover when both layers are present.
    if (periodBudgetLimit <= 0) return envelopeShare;
    return envelopeShare < periodBudgetLimit
        ? envelopeShare
        : periodBudgetLimit;
  }
}
