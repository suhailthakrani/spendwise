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
    required this.totalSpentToday,
    required this.totalSpentThisMonth,
    required this.monthlyBudget,
    required this.categorySpending,
    required this.recentExpenseIds,
  });

  final double totalSpentToday;
  final double totalSpentThisMonth;
  final double monthlyBudget;
  final List<CategorySpending> categorySpending;
  final List<String> recentExpenseIds;

  double get budgetRemaining => monthlyBudget - totalSpentThisMonth;
  double get budgetProgress =>
      monthlyBudget > 0 ? (totalSpentThisMonth / monthlyBudget).clamp(0.0, 1.0) : 0.0;
}
