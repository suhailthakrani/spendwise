import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _short = DateFormat('MMM d, yyyy');
  static final DateFormat _medium = DateFormat('EEEE, MMM d');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');

  static String short(DateTime date) => _short.format(date);
  static String medium(DateTime date) => _medium.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String time(DateTime date) => _time.format(date);
  static String dayMonth(DateTime date) => DateFormat('d MMM').format(date);

  /// Ordinal day label, e.g. `1st`, `2nd`, `3rd`, `11th`.
  static String dayOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    return switch (day % 10) {
      1 => '${day}st',
      2 => '${day}nd',
      3 => '${day}rd',
      _ => '${day}th',
    };
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return short(date);
  }

  /// Short range label, e.g. `15 Sep → 14 Oct`.
  static String periodRange(DateTime start, DateTime end) {
    return '${dayMonth(start)} → ${dayMonth(end)}';
  }

  /// Whole days from [asOf] (default: today) until [end], not counting today.
  ///
  /// Returns `0` when [end] is today or in the past.
  static int daysLeftInPeriod(DateTime end, {DateTime? asOf}) {
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return endDay.difference(today).inDays.clamp(0, 366);
  }

  /// e.g. `15 Sep → 14 Oct · 12 days left` when [asOf] falls in range.
  static String budgetCycleLabel(
    DateTime start,
    DateTime end, {
    DateTime? asOf,
  }) {
    final range = periodRange(start, end);
    final now = asOf ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    if (today.isBefore(startDay) || today.isAfter(endDay)) return range;
    final left = daysLeftInPeriod(end, asOf: today);
    if (left == 0) return '$range · last day';
    if (left == 1) return '$range · 1 day left';
    return '$range · $left days left';
  }
}
