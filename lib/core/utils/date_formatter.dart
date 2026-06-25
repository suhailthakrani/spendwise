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
}
