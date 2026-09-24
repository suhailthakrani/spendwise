/// A single ranked observation about spending behaviour.
class Insight {
  const Insight({
    required this.id,
    required this.title,
    required this.body,
    required this.severity,
    required this.kind,
  });

  final String id;
  final String title;
  final String body;
  /// 0–1; higher ranks first in the monthly review.
  final double severity;
  final String kind;
}

class MonthlyReview {
  const MonthlyReview({
    required this.insights,
    required this.summary,
  });

  final List<Insight> insights;
  final String summary;
}

/// Pure detectors for notable month-over-month spending patterns.
class InsightEngine {
  const InsightEngine();

  MonthlyReview analyze({
    required List<({DateTime date, double amount, String categoryId, String type})>
        transactions,
    required DateTime now,
    required Map<String, double> categoryBudgets,
    required Map<String, String> categoryNames,
  }) {
    final insights = <Insight>[
      if (_unusualSpend(transactions, now) case final insight?) insight,
      if (_acceleration(transactions, now) case final insight?) insight,
      ..._categoryOverspend(transactions, now, categoryBudgets, categoryNames),
      if (_recurringAmountChange(transactions, now, categoryNames)
          case final insight?)
        insight,
      if (_incomeChange(transactions, now) case final insight?) insight,
    ];

    insights.sort((a, b) => b.severity.compareTo(a.severity));

    if (insights.isEmpty) {
      return const MonthlyReview(
        insights: [],
        summary: "You're on track. No notable changes this period.",
      );
    }

    final top = insights.first;
    return MonthlyReview(
      insights: List.unmodifiable(insights),
      summary: '${insights.length} notable change${insights.length == 1 ? '' : 's'}. '
          'Top: ${top.title}',
    );
  }

  Insight? _unusualSpend(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime now,
  ) {
    final thisMonth = _expenseTotal(txns, now.year, now.month);
    final prior = <double>[];
    for (var i = 1; i <= 3; i++) {
      final m = DateTime(now.year, now.month - i, 1);
      prior.add(_expenseTotal(txns, m.year, m.month));
    }
    if (prior.every((v) => v <= 0)) return null;
    final avg = prior.reduce((a, b) => a + b) / prior.length;
    if (avg <= 0) return null;
    if (thisMonth <= avg * 1.4) return null;

    final ratio = thisMonth / avg;
    return Insight(
      id: 'unusual_spend',
      title: 'Unusual spending',
      body:
          'This month’s spend is ${(ratio * 100).toStringAsFixed(0)}% of your '
          '3-month average.',
      severity: (ratio - 1.4).clamp(0.0, 1.0) * 0.7 + 0.3,
      kind: 'unusual_spend',
    );
  }

  Insight? _acceleration(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final last7Start = today.subtract(const Duration(days: 6));
    final prior7Start = today.subtract(const Duration(days: 13));
    final prior7End = today.subtract(const Duration(days: 7));

    final last7 = _expenseInRange(txns, last7Start, today);
    final prior7 = _expenseInRange(txns, prior7Start, prior7End);
    final lastAvg = last7 / 7;
    final priorAvg = prior7 / 7;
    if (priorAvg <= 0) return null;
    if (lastAvg <= priorAvg * 1.3) return null;

    final ratio = lastAvg / priorAvg;
    return Insight(
      id: 'acceleration',
      title: 'Spending accelerating',
      body:
          'Daily spend over the last 7 days is ${(ratio * 100).toStringAsFixed(0)}% '
          'of the prior week.',
      severity: (ratio - 1.3).clamp(0.0, 1.0) * 0.6 + 0.35,
      kind: 'acceleration',
    );
  }

  List<Insight> _categoryOverspend(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime now,
    Map<String, double> budgets,
    Map<String, String> names,
  ) {
    if (budgets.isEmpty) return const [];
    final spent = <String, double>{};
    for (final t in txns) {
      if (!_isExpense(t.type)) continue;
      if (t.date.year != now.year || t.date.month != now.month) continue;
      spent[t.categoryId] = (spent[t.categoryId] ?? 0) + t.amount;
    }

    final out = <Insight>[];
    for (final entry in budgets.entries) {
      final used = spent[entry.key] ?? 0;
      if (used <= entry.value) continue;
      final over = used - entry.value;
      final name = names[entry.key] ?? entry.key;
      final ratio = entry.value > 0 ? used / entry.value : 2.0;
      out.add(
        Insight(
          id: 'category_overspend_${entry.key}',
          title: '$name over budget',
          body:
              'Spent ${used.toStringAsFixed(0)} against a limit of '
              '${entry.value.toStringAsFixed(0)} '
              '(${over.toStringAsFixed(0)} over).',
          severity: (ratio - 1.0).clamp(0.0, 1.0) * 0.5 + 0.5,
          kind: 'category_overspend',
        ),
      );
    }
    return out;
  }

  Insight? _recurringAmountChange(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime now,
    Map<String, String> names,
  ) {
    final thisTotals = _categoryExpenseTotals(txns, now.year, now.month);
    final prev = DateTime(now.year, now.month - 1, 1);
    final priorTotals = _categoryExpenseTotals(txns, prev.year, prev.month);
    if (thisTotals.isEmpty || priorTotals.isEmpty) return null;

    String? worstId;
    double worstRatio = 0;
    for (final entry in thisTotals.entries) {
      final prior = priorTotals[entry.key];
      if (prior == null || prior <= 0) continue;
      final ratio = (entry.value - prior).abs() / prior;
      if (ratio > 0.20 && ratio > worstRatio) {
        worstRatio = ratio;
        worstId = entry.key;
      }
    }
    if (worstId == null) return null;

    final name = names[worstId] ?? worstId;
    final thisAmt = thisTotals[worstId]!;
    final priorAmt = priorTotals[worstId]!;
    final direction = thisAmt > priorAmt ? 'up' : 'down';
    return Insight(
      id: 'recurring_amount_change_$worstId',
      title: '$name amount changed',
      body:
          'Category totals moved $direction by ${(worstRatio * 100).toStringAsFixed(0)}% '
          'vs last month.',
      severity: (worstRatio - 0.20).clamp(0.0, 1.0) * 0.5 + 0.25,
      kind: 'recurring_amount_change',
    );
  }

  Insight? _incomeChange(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime now,
  ) {
    final thisIncome = _incomeTotal(txns, now.year, now.month);
    final prev = DateTime(now.year, now.month - 1, 1);
    final lastIncome = _incomeTotal(txns, prev.year, prev.month);
    if (lastIncome <= 0) return null;
    final ratio = (thisIncome - lastIncome).abs() / lastIncome;
    if (ratio <= 0.25) return null;

    final direction = thisIncome > lastIncome ? 'up' : 'down';
    return Insight(
      id: 'income_change',
      title: 'Income shifted',
      body:
          'Income is ${(ratio * 100).toStringAsFixed(0)}% $direction vs last month.',
      severity: (ratio - 0.25).clamp(0.0, 1.0) * 0.5 + 0.4,
      kind: 'income_change',
    );
  }

  static bool _isExpense(String type) =>
      type == 'expense' || type.toLowerCase() == 'expense';

  static bool _isIncome(String type) =>
      type == 'income' || type.toLowerCase() == 'income';

  static double _expenseTotal(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    int year,
    int month,
  ) {
    var sum = 0.0;
    for (final t in txns) {
      if (!_isExpense(t.type)) continue;
      if (t.date.year == year && t.date.month == month) sum += t.amount;
    }
    return sum;
  }

  static double _incomeTotal(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    int year,
    int month,
  ) {
    var sum = 0.0;
    for (final t in txns) {
      if (!_isIncome(t.type)) continue;
      if (t.date.year == year && t.date.month == month) sum += t.amount;
    }
    return sum;
  }

  static double _expenseInRange(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    DateTime start,
    DateTime end,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59);
    var sum = 0.0;
    for (final t in txns) {
      if (!_isExpense(t.type)) continue;
      if (!t.date.isBefore(s) && !t.date.isAfter(e)) sum += t.amount;
    }
    return sum;
  }

  static Map<String, double> _categoryExpenseTotals(
    List<({DateTime date, double amount, String categoryId, String type})> txns,
    int year,
    int month,
  ) {
    final map = <String, double>{};
    for (final t in txns) {
      if (!_isExpense(t.type)) continue;
      if (t.date.year != year || t.date.month != month) continue;
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }
}
