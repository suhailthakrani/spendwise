import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/smart_greeting.dart';
import 'package:spendwise/data/models/dashboard_stats.dart';

DashboardStats _stats({
  double spentToday = 0,
  double spentPeriod = 0,
  double budget = 0,
  DateTime? periodStart,
  DateTime? periodEnd,
}) {
  return DashboardStats(
    totalSpentToday: spentToday,
    totalSpentThisMonth: spentPeriod,
    budgetSpent: spentPeriod,
    monthlyBudget: budget,
    categorySpending: const [],
    recentExpenseIds: const [],
    budgetPeriodStart: periodStart,
    budgetPeriodEnd: periodEnd,
  );
}

void main() {
  test('uses first name in evening fallback', () {
    final greeting = SmartGreeting.resolve(
      stats: _stats(spentToday: 200, budget: 50000, spentPeriod: 20000),
      userName: 'Suhail Kumar',
      now: DateTime(2026, 10, 2, 19),
    );
    expect(greeting, 'Evening, Suhail');
  });

  test('flags over budget', () {
    final greeting = SmartGreeting.resolve(
      stats: _stats(spentPeriod: 52000, budget: 50000),
      userName: 'Suhail',
      now: DateTime(2026, 10, 2, 14),
    );
    expect(greeting, 'Over budget, Suhail');
  });

  test('celebrates new period', () {
    final greeting = SmartGreeting.resolve(
      stats: _stats(
        budget: 50000,
        periodStart: DateTime(2026, 10, 2),
        periodEnd: DateTime(2026, 11, 1),
      ),
      now: DateTime(2026, 10, 2, 10),
    );
    expect(greeting, 'New period starts today');
  });

  test('fresh start when nothing spent this morning', () {
    final greeting = SmartGreeting.resolve(
      stats: _stats(budget: 50000, spentPeriod: 900),
      now: DateTime(2026, 10, 2, 8),
    );
    expect(greeting, 'Fresh start today');
  });

  test('weekend morning without name', () {
    final greeting = SmartGreeting.resolve(
      stats: _stats(spentToday: 100, budget: 50000, spentPeriod: 20000),
      now: DateTime(2026, 10, 3, 9), // Saturday
    );
    expect(greeting, 'Happy weekend');
  });
}
