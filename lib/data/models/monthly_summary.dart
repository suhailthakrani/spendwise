class MonthlySummary {
  const MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpenses,
    required this.categoryBreakdown,
  });

  final int month;
  final int year;
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> categoryBreakdown;

  double get balance => totalIncome - totalExpenses;
}
