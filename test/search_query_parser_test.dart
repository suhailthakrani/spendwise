import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/services/search_query_parser.dart';

void main() {
  final now = DateTime(2026, 9, 23);

  test('parses above / over / > as minAmount', () {
    expect(
      SearchQueryParser.parse('coffee above 5000', now: now).minAmount,
      5000,
    );
    expect(
      SearchQueryParser.parse('over 2500.5 lunch', now: now).minAmount,
      2500.5,
    );
    expect(SearchQueryParser.parse('>100 groceries', now: now).minAmount, 100);
  });

  test('parses below / under / < as maxAmount', () {
    expect(
      SearchQueryParser.parse('snacks below 100', now: now).maxAmount,
      100,
    );
    expect(SearchQueryParser.parse('under 50', now: now).maxAmount, 50);
    expect(SearchQueryParser.parse('<75 taxi', now: now).maxAmount, 75);
  });

  test('parses relative date ranges', () {
    final thisMonth = SearchQueryParser.parse('uber this month', now: now);
    expect(thisMonth.startDate, DateTime(2026, 9, 1));
    expect(thisMonth.endDate!.month, 9);
    expect(thisMonth.text, 'uber');

    final lastMonth = SearchQueryParser.parse('last month', now: now);
    expect(lastMonth.startDate, DateTime(2026, 8, 1));
    expect(lastMonth.endDate, DateTime(2026, 8, 31, 23, 59, 59));

    final last3 = SearchQueryParser.parse('last 3 months', now: now);
    expect(last3.startDate, DateTime(2026, 7, 1));
    expect(last3.endDate!.day, 23);

    final thisWeek = SearchQueryParser.parse('this week', now: now);
    // Sep 23 2026 is Wednesday (weekday 3) → week starts Mon Sep 21
    expect(thisWeek.startDate, DateTime(2026, 9, 21));
  });

  test('extracts #tags and free text', () {
    final q = SearchQueryParser.parse(
      'dinner #food #work above 200',
      now: now,
    );
    expect(q.tags, ['food', 'work']);
    expect(q.minAmount, 200);
    expect(q.text, 'dinner');
  });

  test('empty / plain text returns free text only', () {
    final q = SearchQueryParser.parse('  monthly rent  ', now: now);
    expect(q.text, 'monthly rent');
    expect(q.minAmount, isNull);
    expect(q.maxAmount, isNull);
    expect(q.startDate, isNull);
    expect(q.tags, isEmpty);
  });

  test('wallet words stay in free text', () {
    final q = SearchQueryParser.parse('coffee cash bank', now: now);
    expect(q.text, 'coffee cash bank');
  });
}
