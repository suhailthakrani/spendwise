import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/core/utils/currency_display.dart';
import 'package:spendwise/data/models/expense.dart';
import 'package:spendwise/data/models/insights_period.dart';
import 'package:spendwise/data/models/payment_method.dart';
import 'package:spendwise/data/repositories/report_repository.dart';

void main() {
  final now = DateTime(2026, 8, 19);
  const currency = CurrencyDisplay(displayCurrencyCode: 'USD');

  Expense expense(String id, double amount, DateTime date) {
    return Expense(
      id: id,
      amount: amount,
      categoryId: 'food',
      note: '',
      date: date,
      paymentMethod: PaymentMethod.cash,
    );
  }

  final expenses = [
    expense('aug', 100, DateTime(2026, 8, 10)),
    expense('jul', 50, DateTime(2026, 7, 10)),
    expense('jan25', 25, DateTime(2025, 1, 10)),
  ];

  InsightsReport report(InsightsPeriod period, [List<Expense>? items]) {
    return ReportRepository.summarizePeriods(
      period: period,
      expenses: items ?? expenses,
      currency: currency,
      now: now,
    );
  }

  test('month covers only the current calendar month', () {
    final buckets = InsightsPeriod.oneMonth.historyBuckets(now: now);
    expect(buckets, hasLength(1));
    expect(buckets.single.label, 'August 2026');

    final result = report(InsightsPeriod.oneMonth);
    expect(result.history, hasLength(1));
    expect(result.range.totalExpenses, 100);
    expect(result.history.single.totalExpenses, 100);
  });

  test('3 month covers the last three calendar months', () {
    final buckets = InsightsPeriod.threeMonths.historyBuckets(now: now);
    expect(buckets.map((bucket) => bucket.label), [
      'June 2026',
      'July 2026',
      'August 2026',
    ]);

    final result = report(InsightsPeriod.threeMonths);
    expect(result.range.totalExpenses, 150);
    expect(result.history.last.totalExpenses, 100);
    expect(result.history[1].totalExpenses, 50);
    expect(result.history.first.totalExpenses, 0);
  });

  test('6 month and 1 year use rolling monthly windows', () {
    expect(
      InsightsPeriod.sixMonths.historyBuckets(now: now),
      hasLength(6),
    );
    expect(
      InsightsPeriod.sixMonths.historyBuckets(now: now).first.label,
      'March 2026',
    );

    final year = InsightsPeriod.oneYear.historyBuckets(now: now);
    expect(year, hasLength(12));
    expect(year.first.label, 'September 2025');
    expect(year.last.label, 'August 2026');

    final result = report(InsightsPeriod.oneYear);
    expect(result.range.totalExpenses, 150);
    expect(result.history, hasLength(12));
  });

  test('all time starts at the earliest expense and sums everything', () {
    final result = report(InsightsPeriod.allTime);
    expect(result.range.totalExpenses, 175);
    expect(result.history.first.label, 'January 2025');
    expect(result.history.last.label, 'August 2026');
    expect(
      result.history
          .firstWhere((item) => item.label == 'January 2025')
          .totalExpenses,
      25,
    );
  });

  test('all time uses yearly buckets when history is longer than 24 months',
      () {
    final longHistory = [
      expense('old', 10, DateTime(2022, 3, 1)),
      ...expenses,
    ];
    final result = report(InsightsPeriod.allTime, longHistory);
    expect(result.history.map((item) => item.label), [
      '2022',
      '2023',
      '2024',
      '2025',
      '2026',
    ]);
    expect(result.range.totalExpenses, 185);
    expect(result.historyTitle, 'Yearly history');
  });
}
