class Budget {
  const Budget({
    required this.id,
    required this.name,
    required this.limit,
    required this.spent,
    this.categoryId,
    this.isMonthly = true,
  });

  final String id;
  final String name;
  /// Stored in the app's base currency (USD). Display uses global preference.
  final double limit;
  final double spent;
  final String? categoryId;
  final bool isMonthly;

  double get remaining => limit - spent;
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > limit;
}
