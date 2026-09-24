/// A spend that is logged but kept out of the budget.
class MoneyLog {
  const MoneyLog({
    required this.id,
    required this.amount,
    required this.message,
    required this.date,
  });

  final String id;

  /// Stored in the app's base currency (USD).
  final double amount;
  final String message;
  final DateTime date;

  static List<MoneyLog> inMonth(List<MoneyLog> logs, DateTime month) {
    return [
      for (final log in logs)
        if (log.date.year == month.year && log.date.month == month.month) log,
    ];
  }

  static double total(Iterable<MoneyLog> logs) {
    return logs.fold(0.0, (sum, log) => sum + log.amount);
  }
}
