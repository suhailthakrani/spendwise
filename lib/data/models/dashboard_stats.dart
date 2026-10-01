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

  /// Active budget-period net: income − expenses (display currency).
  /// Window comes from the budget start day (any day 1–31), not calendar month.
  /// Money log is intentionally excluded — it is independent of the ledger.
  final double totalBalance;
  final double totalIncomeThisMonth;
  final double totalSpentToday;

  /// Expense total for the active budget period (home “Spent” chip).
  final double totalSpentThisMonth;

  /// Same window as [totalSpentThisMonth] — used for Remaining / progress.
  final double budgetSpent;

  /// Effective limit for the active overall budget (includes rollover).
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
