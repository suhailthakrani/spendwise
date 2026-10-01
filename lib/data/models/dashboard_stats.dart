class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  final String categoryId;
  final double amount;
  final double percentage;
}

class DashboardStats {
  const DashboardStats({
    required this.totalBalance,
    required this.totalIncomeThisMonth,
    required this.totalSpentToday,
    required this.totalSpentThisMonth,
    required this.budgetSpent,
    required this.monthlyBudget,
    required this.categorySpending,
    required this.recentExpenseIds,
    this.budgetPeriodStart,
    this.budgetPeriodEnd,
  });

  /// This month’s net: income − expenses (display currency).
  /// Past months are excluded so old spend does not drag the hero negative.
  /// Money log is intentionally excluded — it is independent of the ledger.
  final double totalBalance;
  final double totalIncomeThisMonth;
  final double totalSpentToday;

  /// Calendar-month expense total (dashboard “Spent” / Remaining spend).
  final double totalSpentThisMonth;

  /// Spend counted toward the home-card Remaining chip (current calendar month).
  final double budgetSpent;

  /// Effective monthly budget limit for the current calendar month.
  final double monthlyBudget;
  final DateTime? budgetPeriodStart;
  final DateTime? budgetPeriodEnd;
  final List<CategorySpending> categorySpending;
  final List<String> recentExpenseIds;

  double get budgetRemaining => monthlyBudget - budgetSpent;
  double get budgetProgress =>
      monthlyBudget > 0 ? (budgetSpent / monthlyBudget).clamp(0.0, 1.0) : 0.0;

  bool get hasBudgetPeriod =>
      budgetPeriodStart != null && budgetPeriodEnd != null;
}
