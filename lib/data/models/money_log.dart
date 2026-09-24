/// Money recorded outside the budget. [MoneyLogDirection.out] is money leaving;
/// [MoneyLogDirection.incoming] is money coming in.
enum MoneyLogDirection {
  out,
  incoming;

  bool get isIncoming => this == MoneyLogDirection.incoming;

  String get storageValue => isIncoming ? 'in' : 'out';

  static MoneyLogDirection fromStorage(String? value) {
    return value == 'in' ? MoneyLogDirection.incoming : MoneyLogDirection.out;
  }
}

/// An amount logged on purpose so it stays out of budgets and expense totals.
class MoneyLog {
  const MoneyLog({
    required this.id,
    required this.amount,
    required this.message,
    required this.date,
    this.direction = MoneyLogDirection.out,
  });

  final String id;

  /// Stored in the app's base currency (USD).
  final double amount;
  final String message;
  final DateTime date;
  final MoneyLogDirection direction;

  static List<MoneyLog> inMonth(List<MoneyLog> logs, DateTime month) {
    return [
      for (final log in logs)
        if (log.date.year == month.year && log.date.month == month.month) log,
    ];
  }

  static double totalOut(Iterable<MoneyLog> logs) {
    return logs
        .where((log) => !log.direction.isIncoming)
        .fold(0.0, (sum, log) => sum + log.amount);
  }

  static double totalIn(Iterable<MoneyLog> logs) {
    return logs
        .where((log) => log.direction.isIncoming)
        .fold(0.0, (sum, log) => sum + log.amount);
  }
}
