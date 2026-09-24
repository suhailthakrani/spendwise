enum BudgetPeriodType {
  weekly,
  monthly,
  yearly,
  custom,
  event;

  static BudgetPeriodType fromDb(String value) {
    for (final type in BudgetPeriodType.values) {
      if (type.name == value) return type;
    }
    return BudgetPeriodType.monthly;
  }

  String get label => switch (this) {
        BudgetPeriodType.weekly => 'Weekly',
        BudgetPeriodType.monthly => 'Monthly',
        BudgetPeriodType.yearly => 'Yearly',
        BudgetPeriodType.custom => 'Custom',
        BudgetPeriodType.event => 'Event',
      };
}
