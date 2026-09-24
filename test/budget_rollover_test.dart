import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/services/budget_rollover.dart';

void main() {
  group('unusedToRollover', () {
    test('carries unused limit plus prior rollover when enabled', () {
      // Period A: limit 1000, spent 700 → 300 unused
      final toNext = BudgetRollover.unusedToRollover(
        limit: 1000,
        spent: 700,
        priorRollover: 0,
        enabled: true,
      );
      expect(toNext, 300);

      // Period B: receives 300, limit 1000, spent 800 → carry 500
      final across = BudgetRollover.unusedToRollover(
        limit: 1000,
        spent: 800,
        priorRollover: toNext,
        enabled: true,
      );
      expect(across, 500);
    });

    test('returns 0 when disabled even if unused remains', () {
      expect(
        BudgetRollover.unusedToRollover(
          limit: 1000,
          spent: 200,
          priorRollover: 50,
          enabled: false,
        ),
        0,
      );
    });

    test('returns 0 when overspent including prior rollover', () {
      expect(
        BudgetRollover.unusedToRollover(
          limit: 1000,
          spent: 1200,
          priorRollover: 50,
          enabled: true,
        ),
        0,
      );
    });
  });

  group('effectiveLimit', () {
    test('adds rollover to base limit', () {
      expect(
        BudgetRollover.effectiveLimit(limit: 1000, rolloverAmount: 250),
        1250,
      );
    });
  });

  group('envelopeSpendWithoutDoubleCount', () {
    test('attributes only envelope allocation, not full category spend', () {
      // Category spent 150; envelope owns 60; period budget 200.
      // Envelope share is 60 — period remaining should not also subtract 150.
      final envelopeShare = BudgetRollover.envelopeSpendWithoutDoubleCount(
        categorySpend: 150,
        envelopeAllocated: 60,
        periodBudgetLimit: 200,
      );
      expect(envelopeShare, 60);

      final periodOnly = 150 - envelopeShare;
      expect(periodOnly, 90);
    });

    test('caps at category spend when allocation is larger', () {
      expect(
        BudgetRollover.envelopeSpendWithoutDoubleCount(
          categorySpend: 40,
          envelopeAllocated: 100,
          periodBudgetLimit: 200,
        ),
        40,
      );
    });

    test('never exceeds period budget limit', () {
      expect(
        BudgetRollover.envelopeSpendWithoutDoubleCount(
          categorySpend: 500,
          envelopeAllocated: 400,
          periodBudgetLimit: 100,
        ),
        100,
      );
    });
  });
}
