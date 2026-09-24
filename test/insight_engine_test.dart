import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/services/insight_engine.dart';

void main() {
  const engine = InsightEngine();
  final now = DateTime(2026, 9, 20);

  ({DateTime date, double amount, String categoryId, String type}) txn({
    required DateTime date,
    required double amount,
    String categoryId = 'food',
    String type = 'expense',
  }) {
    return (
      date: date,
      amount: amount,
      categoryId: categoryId,
      type: type,
    );
  }

  test('no insight path when spending is steady', () {
    final txns = [
      txn(date: DateTime(2026, 9, 5), amount: 100),
      txn(date: DateTime(2026, 8, 5), amount: 100),
      txn(date: DateTime(2026, 7, 5), amount: 100),
      txn(date: DateTime(2026, 6, 5), amount: 100),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {'food': 500},
      categoryNames: const {'food': 'Food'},
    );

    expect(review.insights, isEmpty);
    expect(
      review.summary,
      "You're on track. No notable changes this period.",
    );
  });

  test('unusualSpend when this month exceeds 1.4x prior 3-month average', () {
    final txns = [
      txn(date: DateTime(2026, 9, 5), amount: 1500),
      txn(date: DateTime(2026, 8, 5), amount: 100),
      txn(date: DateTime(2026, 7, 5), amount: 100),
      txn(date: DateTime(2026, 6, 5), amount: 100),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {},
      categoryNames: const {},
    );

    expect(review.insights.any((i) => i.kind == 'unusual_spend'), isTrue);
  });

  test('acceleration when last 7 days average exceeds prior week by 1.3x', () {
    final txns = [
      // last 7 days (Sep 14–20): 700 total → 100/day
      txn(date: DateTime(2026, 9, 14), amount: 100),
      txn(date: DateTime(2026, 9, 15), amount: 100),
      txn(date: DateTime(2026, 9, 16), amount: 100),
      txn(date: DateTime(2026, 9, 17), amount: 100),
      txn(date: DateTime(2026, 9, 18), amount: 100),
      txn(date: DateTime(2026, 9, 19), amount: 100),
      txn(date: DateTime(2026, 9, 20), amount: 100),
      // prior 7 days (Sep 7–13): 350 total → 50/day (ratio 2.0)
      txn(date: DateTime(2026, 9, 7), amount: 50),
      txn(date: DateTime(2026, 9, 8), amount: 50),
      txn(date: DateTime(2026, 9, 9), amount: 50),
      txn(date: DateTime(2026, 9, 10), amount: 50),
      txn(date: DateTime(2026, 9, 11), amount: 50),
      txn(date: DateTime(2026, 9, 12), amount: 50),
      txn(date: DateTime(2026, 9, 13), amount: 50),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {},
      categoryNames: const {},
    );

    expect(review.insights.any((i) => i.kind == 'acceleration'), isTrue);
  });

  test('categoryOverspend when category exceeds budget', () {
    final txns = [
      txn(date: DateTime(2026, 9, 5), amount: 300, categoryId: 'food'),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {'food': 200},
      categoryNames: const {'food': 'Food'},
    );

    expect(review.insights.any((i) => i.kind == 'category_overspend'), isTrue);
    expect(review.insights.first.title, contains('Food'));
  });

  test('recurringAmountChange when category totals move >20%', () {
    final txns = [
      txn(date: DateTime(2026, 9, 5), amount: 150, categoryId: 'rent'),
      txn(date: DateTime(2026, 8, 5), amount: 100, categoryId: 'rent'),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {},
      categoryNames: const {'rent': 'Rent'},
    );

    expect(
      review.insights.any((i) => i.kind == 'recurring_amount_change'),
      isTrue,
    );
  });

  test('incomeChange when income moves >25%', () {
    final txns = [
      txn(
        date: DateTime(2026, 9, 1),
        amount: 130000,
        categoryId: 'salary',
        type: 'income',
      ),
      txn(
        date: DateTime(2026, 8, 1),
        amount: 100000,
        categoryId: 'salary',
        type: 'income',
      ),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {},
      categoryNames: const {},
    );

    expect(review.insights.any((i) => i.kind == 'income_change'), isTrue);
  });

  test('insights are ranked by severity descending', () {
    final txns = [
      txn(date: DateTime(2026, 9, 5), amount: 2000), // unusual
      txn(date: DateTime(2026, 8, 5), amount: 100),
      txn(date: DateTime(2026, 7, 5), amount: 100),
      txn(date: DateTime(2026, 6, 5), amount: 100),
      txn(date: DateTime(2026, 9, 5), amount: 500, categoryId: 'food'),
    ];

    final review = engine.analyze(
      transactions: txns,
      now: now,
      categoryBudgets: const {'food': 100},
      categoryNames: const {'food': 'Food'},
    );

    expect(review.insights.length, greaterThanOrEqualTo(2));
    for (var i = 0; i < review.insights.length - 1; i++) {
      expect(
        review.insights[i].severity,
        greaterThanOrEqualTo(review.insights[i + 1].severity),
      );
    }
  });
}
