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

  /// Net of all income minus expenses (what people check first).
  final double totalBalance;
  final double totalIncomeThisMonth;
  final double totalSpentToday;

  /// Calendar-month expense total (dashboard “Spent” chip).
  final double totalSpentThisMonth;

  /// Spend inside the active monthly budget window (may cross months).
  final double budgetSpent;

  /// Effective monthly budget limit (includes rollover), display currency.
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
