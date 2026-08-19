/// Lookback window for Insights.
enum InsightsPeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  allTime;

  String get shortLabel => switch (this) {
        InsightsPeriod.oneMonth => 'Month',
        InsightsPeriod.threeMonths => '3 month',
        InsightsPeriod.sixMonths => '6 month',
        InsightsPeriod.oneYear => '1 year',
        InsightsPeriod.allTime => 'All time',
      };

  String get rangeCaption => switch (this) {
        InsightsPeriod.oneMonth => 'This month',
        InsightsPeriod.threeMonths => 'Last 3 months',
        InsightsPeriod.sixMonths => 'Last 6 months',
        InsightsPeriod.oneYear => 'Last 12 months',
        InsightsPeriod.allTime => 'All time',
      };

  String get spendLabel => rangeCaption;

  static const monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const monthFullNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Oldest-first history buckets for this lookback window.
  List<PeriodBucket> historyBuckets({
    DateTime? now,
    DateTime? earliestExpense,
  }) {
    final n = now ?? DateTime.now();
    switch (this) {
      case InsightsPeriod.oneMonth:
        return [PeriodBucket.month(n)];
      case InsightsPeriod.threeMonths:
        return PeriodBucket.months(count: 3, now: n);
      case InsightsPeriod.sixMonths:
        return PeriodBucket.months(count: 6, now: n);
      case InsightsPeriod.oneYear:
        return PeriodBucket.months(count: 12, now: n);
      case InsightsPeriod.allTime:
        final earliest = earliestExpense ?? n;
        final start = DateTime(earliest.year, earliest.month, 1);
        final end = DateTime(n.year, n.month, 1);
        final monthCount =
            (end.year - start.year) * 12 + end.month - start.month + 1;
        if (monthCount > 24) {
          return [
            for (var year = start.year; year <= n.year; year++)
              PeriodBucket.year(year),
          ];
        }
        return PeriodBucket.months(count: monthCount.clamp(1, 24), now: n);
    }
  }
}

class PeriodBucket {
  const PeriodBucket({
    required this.label,
    required this.shortLabel,
    required this.leadingLabel,
    required this.start,
    required this.end,
  });

  factory PeriodBucket.month(DateTime month) {
    final date = DateTime(month.year, month.month, 1);
    return PeriodBucket(
      label: '${InsightsPeriod.monthFullNames[date.month - 1]} ${date.year}',
      shortLabel: InsightsPeriod.monthNames[date.month - 1],
      leadingLabel: InsightsPeriod.monthNames[date.month - 1],
      start: date,
      end: DateTime(date.year, date.month + 1, 0, 23, 59, 59),
    );
  }

  factory PeriodBucket.year(int year) {
    return PeriodBucket(
      label: '$year',
      shortLabel: '$year',
      leadingLabel: '$year',
      start: DateTime(year, 1, 1),
      end: DateTime(year, 12, 31, 23, 59, 59),
    );
  }

  static List<PeriodBucket> months({
    required int count,
    required DateTime now,
  }) {
    return List.generate(count, (i) {
      return PeriodBucket.month(
        DateTime(now.year, now.month - (count - 1 - i)),
      );
    });
  }

  final String label;
  final String shortLabel;
  final String leadingLabel;
  final DateTime start;
  final DateTime end;

  bool get isYearly => start.month == 1 && start.day == 1 && end.month == 12;

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }
}

class PeriodSummary {
  const PeriodSummary({
    required this.period,
    required this.label,
    required this.shortLabel,
    required this.leadingLabel,
    required this.start,
    required this.end,
    required this.totalExpenses,
    required this.categoryBreakdown,
  });

  final InsightsPeriod period;
  final String label;
  final String shortLabel;
  final String leadingLabel;
  final DateTime start;
  final DateTime end;
  final double totalExpenses;
  final Map<String, double> categoryBreakdown;
}

class InsightsReport {
  const InsightsReport({
    required this.period,
    required this.range,
    required this.history,
  });

  final InsightsPeriod period;
  final PeriodSummary range;
  final List<PeriodSummary> history;

  String get historyTitle => history.isNotEmpty &&
          history.first.start.month == 1 &&
          history.first.start.day == 1 &&
          history.first.end.month == 12
      ? 'Yearly history'
      : 'Monthly history';
}
