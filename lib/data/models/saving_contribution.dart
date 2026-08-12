class SavingContribution {
  const SavingContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.note,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  /// Amount in USD storage currency.
  final double amount;
  final String note;
  final DateTime date;
  final DateTime createdAt;
}
