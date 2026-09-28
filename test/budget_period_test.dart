import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/date_formatter.dart';
import 'package:spendwise/data/models/budget.dart';

void main() {
  group('DateFormatter.dayOrdinal', () {
    test('formats common ordinals', () {
      expect(DateFormatter.dayOrdinal(1), '1st');
      expect(DateFormatter.dayOrdinal(2), '2nd');
      expect(DateFormatter.dayOrdinal(3), '3rd');
      expect(DateFormatter.dayOrdinal(4), '4th');
      expect(DateFormatter.dayOrdinal(11), '11th');
      expect(DateFormatter.dayOrdinal(12), '12th');
      expect(DateFormatter.dayOrdinal(13), '13th');
      expect(DateFormatter.dayOrdinal(21), '21st');
      expect(DateFormatter.dayOrdinal(22), '22nd');
      expect(DateFormatter.dayOrdinal(23), '23rd');
    });
  });

  group('Budget period bounds', () {
    test('defaults to the 1st through month end', () {
      expect(
        Budget.resolvePeriodStart(year: 2026, month: 9),
        DateTime(2026, 9, 1),
      );
      expect(
        Budget.resolvePeriodEnd(year: 2026, month: 9),
        DateTime(2026, 9, 30),
      );
    });

    test('start day 15 runs until day before next 15th', () {
      expect(
        Budget.resolvePeriodStart(year: 2026, month: 9, startDay: 15),
        DateTime(2026, 9, 15),
      );
      expect(
        Budget.resolvePeriodEnd(year: 2026, month: 9, startDay: 15),
        DateTime(2026, 10, 14),
      );
    });

    test('clamps start day in short months', () {
      expect(
        Budget.resolvePeriodStart(year: 2026, month: 2, startDay: 31),
        DateTime(2026, 2, 28),
      );
      // Next cycle clamps Mar 31 → Mar 31, so end is Mar 30.
      expect(
        Budget.resolvePeriodEnd(year: 2026, month: 2, startDay: 31),
        DateTime(2026, 3, 30),
      );
    });

    test('startDay getter falls back to 1', () {
      const budget = Budget(
        id: 'b1',
        name: 'Monthly',
        limit: 100,
        spent: 0,
        year: 2026,
        month: 9,
      );
      expect(budget.startDay, 1);
      expect(budget.periodStart, DateTime(2026, 9, 1));
      expect(budget.periodEnd, DateTime(2026, 9, 30));
    });

    test('honors stored startDate day and cycle end', () {
      final budget = Budget(
        id: 'b1',
        name: 'Monthly',
        limit: 100,
        spent: 0,
        year: 2026,
        month: 9,
        startDate: DateTime(2026, 9, 15),
        endDate: DateTime(2026, 10, 14),
      );
      expect(budget.startDay, 15);
      expect(budget.periodStart, DateTime(2026, 9, 15));
      expect(budget.periodEnd, DateTime(2026, 10, 14));
      expect(budget.isActiveOn(DateTime(2026, 9, 15)), isTrue);
      expect(budget.isActiveOn(DateTime(2026, 10, 10)), isTrue);
      expect(budget.isActiveOn(DateTime(2026, 10, 15)), isFalse);
      expect(budget.isActiveOn(DateTime(2026, 9, 14)), isFalse);
    });
  });

  group('DateFormatter budget cycle labels', () {
    test('periodRange formats short bounds', () {
      expect(
        DateFormatter.periodRange(
          DateTime(2026, 9, 15),
          DateTime(2026, 10, 14),
        ),
        '15 Sep → 14 Oct',
      );
    });

    test('budgetCycleLabel includes days left when in range', () {
      expect(
        DateFormatter.budgetCycleLabel(
          DateTime(2026, 9, 15),
          DateTime(2026, 10, 14),
          asOf: DateTime(2026, 10, 2),
        ),
        '15 Sep → 14 Oct · 12 days left',
      );
    });

    test('budgetCycleLabel omits days left outside range', () {
      expect(
        DateFormatter.budgetCycleLabel(
          DateTime(2026, 9, 15),
          DateTime(2026, 10, 14),
          asOf: DateTime(2026, 9, 1),
        ),
        '15 Sep → 14 Oct',
      );
    });
  });
}
