import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/models/forecast.dart';
import 'package:spendwise/data/services/forecast_service.dart';

void main() {
  final fixedNow = DateTime(2026, 9, 15); // day 15 of 30-day month
  late ForecastService service;

  setUp(() {
    service = ForecastService(clock: () => fixedNow);
  });

  test('projects month-end spend from daily pace', () {
    final result = service.project(
      currentBalance: 100000,
      monthSpendSoFar: 15000, // 1000/day over 15 days
      monthIncomeSoFar: 50000,
      monthlyBudgetLimit: 40000,
      recurring: const [],
      goalContributions: const [],
    );

    expect(result.paceDailySpend, 1000);
    expect(result.projectedMonthEndSpend, 30000); // 1000 * 30
    expect(result.assumptions, 'based on 15 days of this month');
    expect(result.safeToSpendRestOfMonth, 25000); // 40000 - 15000
    expect(result.safeToSpendToday, closeTo(25000 / 15, 0.01));
  });

  test('includes upcoming income and expense commitments after asOf', () {
    final result = service.project(
      currentBalance: 80000,
      monthSpendSoFar: 10000,
      monthIncomeSoFar: 0,
      monthlyBudgetLimit: null,
      recurring: [
        (
          title: 'Rent',
          amount: 20000,
          due: DateTime(2026, 9, 20),
          isIncome: false,
        ),
        (
          title: 'Salary',
          amount: 90000,
          due: DateTime(2026, 9, 25),
          isIncome: true,
        ),
        (
          title: 'Past bill',
          amount: 5000,
          due: DateTime(2026, 9, 10),
          isIncome: false,
        ),
      ],
      goalContributions: [
        (title: 'Emergency fund', amount: 5000, due: DateTime(2026, 9, 28)),
      ],
    );

    expect(result.expectedIncomeRemaining, 90000);
    expect(result.upcomingCommitments, hasLength(3));
    expect(
      result.upcomingCommitments.map((c) => c.kind).toSet(),
      {
        ForecastCommitmentKind.bill,
        ForecastCommitmentKind.income,
        ForecastCommitmentKind.goal,
      },
    );

    // remaining pace spend = 10000/15*30 - 10000 = 10000
    // balance = 80000 - 10000 + 90000 - 20000 - 5000 = 135000
    expect(result.projectedMonthEndBalance, 135000);
  });

  test('budget exhaustion date when pace depletes limit', () {
    final result = service.project(
      currentBalance: 50000,
      monthSpendSoFar: 20000, // ~1333/day
      monthIncomeSoFar: 0,
      monthlyBudgetLimit: 30000,
      recurring: const [],
      goalContributions: const [],
    );

    expect(result.budgetExhaustionDate, isNotNull);
    expect(result.budgetExhaustionDate!.month, 9);
    expect(result.budgetExhaustionDate!.day, lessThanOrEqualTo(30));
  });

  test('whatIf applies absolute spend and income deltas', () {
    final base = service.project(
      currentBalance: 100000,
      monthSpendSoFar: 15000,
      monthIncomeSoFar: 0,
      monthlyBudgetLimit: 40000,
      recurring: const [],
      goalContributions: const [],
    );

    final adjusted = service.whatIf(base, spendDelta: 5000, incomeDelta: 2000);
    expect(adjusted.projectedMonthEndSpend, base.projectedMonthEndSpend + 5000);
    expect(
      adjusted.projectedMonthEndBalance,
      base.projectedMonthEndBalance - 5000 + 2000,
    );
    expect(
      adjusted.expectedIncomeRemaining,
      base.expectedIncomeRemaining + 2000,
    );
  });

  test('WhatIfScenario percentage helper', () {
    final base = service.project(
      currentBalance: 100000,
      monthSpendSoFar: 15000,
      monthIncomeSoFar: 40000,
      monthlyBudgetLimit: null,
      recurring: [
        (
          title: 'Pay',
          amount: 10000,
          due: DateTime(2026, 9, 28),
          isIncome: true,
        ),
      ],
      goalContributions: const [],
    );

    final scenario = const WhatIfScenario(
      name: 'cut 10% spend',
      adjustSpendPct: -0.10,
    );
    final result = scenario.apply(base);
    expect(result.projectedMonthEndSpend, lessThan(base.projectedMonthEndSpend));
    expect(result.assumptions, contains('cut 10% spend'));
  });

  test('uses injected clock when asOf omitted', () {
    final result = service.project(
      currentBalance: 1,
      monthSpendSoFar: 15,
      monthIncomeSoFar: 0,
      monthlyBudgetLimit: null,
      recurring: const [],
      goalContributions: const [],
    );
    expect(result.paceDailySpend, 1); // 15 / 15
    expect(result.assumptions, contains('15 days'));
  });
}
